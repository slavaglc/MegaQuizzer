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
        
        navigationItem.leftBarButtonItem = editButtonItem
        navigationItem.leftBarButtonItem?.tintColor = .white
        
        showAlert(title: "Привет \(userName)", massage: "Добро пожаловать в MegaQuizzer! Ты попал на экран выбора темы. Выбирай и вперед!")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        questions = QuizDataManager.shared.getQuizzes()
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
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            questions.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    @IBAction func quizUnwind(for unwindSeque: UIStoryboardSegue) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       guard let quizVC =
               segue.destination as? QuizViewController else { return }
       guard let indexPath =
               tableView.indexPathForSelectedRow else { return }
        quizVC.quiz = questions[indexPath.row]
        quizVC.name = userName
    }
    
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
