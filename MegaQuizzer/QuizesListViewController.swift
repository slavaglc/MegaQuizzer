//
//  QuizesListTableTableViewController.swift
//  MegaQuizzer
//
//  Created by Максим on 30.07.2021.
//

import UIKit

class QuizesListViewController: UITableViewController {
    
    var questions = QuizDataManager.shared.getQuizzes()
    
    var userName: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let userName = userName else { return }
        
        showAlert(title: "Привет \(userName)", massage: "Добро пожаловать в MegaQuizzer! Ты попал на экран выбора темы. Выбирай и вперед!")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        questions.count
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var content = cell.defaultContentConfiguration()

        content.text = questions[indexPath.row].name
        content.textProperties.color = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        cell.contentConfiguration = content

        return cell
    }
    
    @IBAction func quizUnwind(for unwindSeque: UIStoryboardSegue) {
    }
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//       guard let quizVC =
//               segue.destination as? QuizViewController else { return }
//       guard let indexPath =
//               tableView.indexPathForSelectedRow else { return }
//       let questions = questions[indexPath.row]
//       quizVC.questions = questions
//    }
    
}

extension QuizesListViewController {
    private func showAlert(title: String,
                           massage: String) {
        let alert = UIAlertController(title: title,
                                      message: massage,
                                      preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Понял",
                                        style: .cancel)
        
        alert.addAction(alertAction)
        
        present(alert, animated: true)
    }
}
