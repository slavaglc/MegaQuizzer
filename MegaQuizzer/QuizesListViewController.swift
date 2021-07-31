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
        navigationItem.title = userName
        guard let userName = userName else { return }
        
        showAlert(title: "Привет \(userName)", massage: "Добро пожаловать в MegaQuizzer! Ты попал на экран выбора темы. Выбирай и вперед!")
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
        cell.contentConfiguration = content

        return cell
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
