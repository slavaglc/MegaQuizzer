import UIKit

enum CreatingType {
    case quizName, question
}

class CreatingQuizViewController: UIViewController {
    //MARK: Oulets
    
    @IBOutlet weak private var quizNameTextField: UITextField!
    @IBOutlet weak private var questionTextField: UITextField!
    @IBOutlet weak private var tableView: UITableView!
    
    @IBOutlet weak private var questionStackView: UIStackView!
    @IBOutlet weak private var quizNameStackView: UIStackView!
    
    @IBOutlet private var buttons: [UIButton]!
    
    
    //MARK: Public variables
    
    var creatingType = CreatingType.quizName
    
    //MARK: Private constances
    
    let maxAnswers = 5
    
    //MARK: Private variables
    
    private var quiz: Quiz!
    private var quizName: String!
    private var possibleAnswers = ["Вариант ответа 1", "Вариант ответа 2", "Вариант ответа 3"]
    private var questionCards: [QuestionCard] = []
    private var answerArray: [Answer] = []
    private var truthArray = [false, false, false]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        quizNameTextField.delegate = self
        questionTextField.delegate = self
        setGUI()
    }

    @IBAction func nextTapped(_ sender: UIButton) {
        if sender.tag == 0 {
            if quizNameTextField.text == "" {
            highlightTextField(textField: quizNameTextField, withText: "Введите название викторины", color: .red)
            } else {
                quizName = quizNameTextField.text
                quizNameTextField.resignFirstResponder()
                creatingType = .question
                setGUI()
            }
        } else if sender.tag == 1 {
            showCreatingAnswer(for: possibleAnswers.count)
        } else if sender.tag == 2 {
            guard possibleAnswers.count >= 2 else { return
                showAlert(title: "Постойте!", message: "Должно быть не менее двух вариантов ответа", style: .alert) }
            guard questionTextField.text != "" else { return
                highlightTextField(textField: questionTextField, withText: "Введите вопрос!", color: .red) }
            nextQuestion()
        }
    }
    
    @IBAction func doneTapped(_ sender: UIBarButtonItem) {
        guard questionCards.count > 0 else { return showAlert(title: "Постойте!", message: "Вы не создали ни одного вопроса", style: .alert) }
        quiz = Quiz(name: quizName, questions: questionCards)
        QuizDataManager.shared.saveQuiz(quiz: quiz)
        dismiss(animated: true, completion: nil)
    }
    
    fileprivate func checkCountOfAnswers() {
        if possibleAnswers.count >= maxAnswers {
            buttons[1].isEnabled = false
            buttons[1].isHidden = true
        } else {
            if buttons[1].isEnabled == false {
                buttons[1].moveIn()
            }
            buttons[1].isEnabled = true
        }
    }
    
    fileprivate func showCreatingAnswer(for row: Int){
        var okActionTitle: String!
        var isEditing: Bool!
        
        let alert = UIAlertController(title: "Введите ответ", message: nil, preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        guard let alertTextField = alert.textFields?[0] else { return }
        
        if possibleAnswers.indices.contains(row) {
            isEditing = true
            alertTextField.text = possibleAnswers[row]
            okActionTitle = "Изменить"
        } else {
            isEditing = false
            okActionTitle = "Создать"
        }
        
        let okAction = UIAlertAction(title: okActionTitle, style: .default) { _ in
            guard let answerText = alertTextField.text else { return }
            if isEditing {
            self.possibleAnswers[row] = answerText
            } else {
                self.possibleAnswers.append(answerText)
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "possibleAnswerCell") as! PossibleAnswerTableViewCell
                let switchPosition = cell.truthSwitch.isOn
                self.truthArray.append(switchPosition)
                self.checkCountOfAnswers()
            }
            self.tableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Отменить", style: .destructive, handler: nil)
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        
        
        alertTextField.placeholder = "Ответ"
        present(alert, animated: true)
    }
    
    @objc fileprivate func switchChanged(sender: UISwitch) {
        let row = sender.tag
        truthArray[row] = sender.isOn
        tableView.reloadData()
    }
    
    @objc fileprivate func removeAnswer(sender: UIButton) {
        let row = sender.tag
        possibleAnswers.remove(at: row)
        truthArray.remove(at: row)
        checkCountOfAnswers()
        tableView.reloadData()
    }
    
    private func setGUI() {
        setCornerRadius()
        switch creatingType {
        case .quizName:
            navigationController?.navigationBar.items?.last?.rightBarButtonItem?.isEnabled = false
            quizNameStackView.moveIn()
            questionStackView.isHidden = true
        case .question:
            navigationController?.navigationBar.items?.last?.rightBarButtonItem?.isEnabled = true
            quizNameStackView.moveOut()
            questionStackView.moveIn()
        }
    }
    
    private func setCornerRadius() {
        for button in buttons {
            button.layer.cornerRadius = 10
        }
    }
    
    private func nextQuestion() {
        saveQuestionCard()
        questionStackView.moveNext()
        removeCard()
        checkCountOfAnswers()
    }
    
    private func saveQuestionCard() {
        for (i, text) in possibleAnswers.enumerated() {
            let newAnswer = Answer(answerText: text, isTrue: truthArray[i])
            answerArray.append(newAnswer)
        }
        guard let questionText = questionTextField.text else { return }
        let newQuestionCard = QuestionCard(questionText: questionText, answers: answerArray)
        questionCards.append(newQuestionCard)
        print(questionCards)
    }
    
    private func removeCard() {
        questionTextField.text = ""
        possibleAnswers.removeAll()
        truthArray.removeAll()
        answerArray.removeAll()
        tableView.reloadData()
    }
    
    private func showAlert(title: String, message: String, style: UIAlertController.Style) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        let okAction = UIAlertAction(title: "Ок", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
    private func highlightTextField(textField: UITextField, withText text: String, color: UIColor) {
        UIView.animate(withDuration: 1.0) {
            let placeHolderLabel = textField.subviews.first(where: { NSStringFromClass(type(of: $0)) == "UITextFieldLabel" })
            placeHolderLabel?.tintColor = .red
            textField.moveIn()
            textField.attributedPlaceholder = NSAttributedString(string:                                                        text,
                                                                 attributes: [NSAttributedString.Key.foregroundColor: color.withAlphaComponent(0.5)])
            
        }
    }
}

extension CreatingQuizViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        possibleAnswers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "possibleAnswerCell") as? PossibleAnswerTableViewCell else { return UITableViewCell()}
        
        if possibleAnswers.count < 3 {
            cell.removeAnswerBtn.isHidden = true
        } else {
            cell.removeAnswerBtn.isHidden = false
        }
        cell.possibleAnswerLabel.text = possibleAnswers[indexPath.row]
        cell.truthSwitch.isOn = truthArray[indexPath.row]
        cell.removeAnswerBtn.tag = indexPath.row
        cell.truthSwitch.tag = indexPath.row
        cell.truthSwitch.addTarget(self, action: #selector(switchChanged(sender:)), for: .valueChanged)
        cell.removeAnswerBtn.addTarget(self, action: #selector(removeAnswer(sender:)), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showCreatingAnswer(for: indexPath.row)
    }
}

extension CreatingQuizViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == 0 && creatingType == .quizName {
            nextTapped(buttons[0])
        }
        textField.resignFirstResponder()
        return true
    }
}

extension UIView {
    
    func moveIn() {
        transform = CGAffineTransform(scaleX: 1.35, y: 1.35)
        alpha = 0.0
        isHidden = false
        
        UIView.animate(withDuration: 0.5) {
            self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            self.alpha = 1.0
        }
    }
}

extension UIStackView {
    
        func moveOut() {
            transform = CGAffineTransform(scaleX: 1.35, y: 1.35)
            alpha = 1.0
            
            UIView.animate(withDuration: 0.7) {
                self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                self.alpha = 0.0
            } completion: { isFinished in
                self.isHidden = true
            }
    }
    
    func moveNext() {
        transform = CGAffineTransform(scaleX: 0.0, y: 1.0)
        alpha = 0.0
        
        UIView.animate(withDuration: 0.5) {
            self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            self.alpha = 1.0
        }
    }
}

