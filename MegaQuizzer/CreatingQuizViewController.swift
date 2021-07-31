import UIKit

enum CreatingType {
    case quizName
    case question
}

class CreatingQuizViewController: UIViewController {
    //MARK: Oulets
    @IBOutlet weak var quizNameTextField: UITextField!
    @IBOutlet weak var questionTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBOutlet weak var questionStackView: UIStackView!
    @IBOutlet weak var quizNameStackView: UIStackView!
    //MARK: Public variables
    var creatingType = CreatingType.quizName
    
    //MARK: Private variables
    private var quizName: String!
    private var possibleAnswers = ["Вариант ответа 1", "Вариант ответа 2", "Вариант ответа 3"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setGUI()
    }

    @IBAction func nextTapped(_ sender: UIButton) {
        if sender.tag == 0 {
            if quizNameTextField.text == "" {
            highlightTextField(textField: quizNameTextField, withText: "Введите название викторины", color: .red)
            } else {
                creatingType = .question
                setGUI()
            }
        } else if sender.tag == 1 {
            showCreatingAnswer(for: possibleAnswers.count)
        }
    }
    
    @IBAction func doneTapped(_ sender: UIBarButtonItem) {
        
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
        
        let okAction = UIAlertAction(title: okActionTitle, style: .default) { action in
            guard let answerText = alertTextField.text else { return }
            if isEditing {
            self.possibleAnswers[row] = answerText
            } else {
                self.possibleAnswers.append(answerText)
            }
            self.tableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Отменить", style: .destructive, handler: nil)
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        
        
        alertTextField.placeholder = "Ответ"
        present(alert, animated: true)
    }
    
    private func setGUI() {
        switch creatingType {
        case .quizName:
            navigationController?.navigationBar.items?.last?.rightBarButtonItem?.isEnabled = false
            
            quizNameStackView.moveIn()
            quizNameStackView.isHidden = false
            questionStackView.isHidden = true
        case .question:
            navigationController?.navigationBar.items?.last?.rightBarButtonItem?.isEnabled = true
            quizNameStackView.isHidden = true
            questionStackView.isHidden = false
            questionStackView.moveIn()
            break
        }
    }
    
    private func showAlert(title: String, message: String, style: UIAlertController.Style) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
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
        cell.possibleAnswerLabel.text = possibleAnswers[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showCreatingAnswer(for: indexPath.row)
    }
}

extension UIView {
    func moveIn() {
        self.transform = CGAffineTransform(scaleX: 1.35, y: 1.35)
        self.alpha = 0.0
        
        
        UIView.animate(withDuration: 0.5) {
            self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            self.alpha = 1.0
        }
    }
    
    func moveOut() {
        self.transform = CGAffineTransform(scaleX: 1.35, y: 1.35)
        self.alpha = 1.0
        
        
        UIView.animate(withDuration: 0.5) {
            self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            self.alpha = 0.0
        }
    }
}
