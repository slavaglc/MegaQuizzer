import UIKit

class CreatingQuizViewController: UIViewController {

    @IBOutlet weak var quizNameTextField: UITextField!
    @IBOutlet weak var questionTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var questionStackView: UIStackView!
    @IBOutlet weak var quizNameStackView: UIStackView!
    
    private var possibleAnswers = ["Вариант ответа 1", " Вариант ответа 2", "Вариант ответа 3"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    
    
    @IBAction func nextTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func doneTapped(_ sender: UIBarButtonItem) {
    }
    
    
    
}

extension CreatingQuizViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        <#code#>
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
    }
    
    
}
