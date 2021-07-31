import UIKit

class CreatingQuizViewController: UIViewController {

    @IBOutlet weak var quizNameTextField: UITextField!
    @IBOutlet weak var questionTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var questionStackView: UIStackView!
    @IBOutlet weak var quizNameStackView: UIStackView!
    
    private var possibleAnswers = ["Вариант ответа 1", "Вариант ответа 2", "Вариант ответа 3"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func nextTapped(_ sender: UIButton) {
        if sender.tag == 1 {
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
