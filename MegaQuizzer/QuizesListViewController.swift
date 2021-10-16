//
//  QuizesListTableTableViewController.swift
//  MegaQuizzer
//
//  Created by Максим on 30.07.2021.
//

import UIKit

final class QuizesListViewController: UITableViewController {
    
    
    var quizzes: [Quiz] = []
    var userName: String?
    //[Quiz(name: "test", questions: [QuestionCard(questionText: "", answers: [Answer(answerText: "", isTrue: true)])])]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let userName = userName else { return }
        
        navigationItem.leftBarButtonItem = editButtonItem
        navigationItem.leftBarButtonItem?.tintColor = .white
        
        showAlert(title: "Привет \(userName)", massage: "Добро пожаловать в MegaQuizzer! Ты попал на экран выбора темы. Выбирай и вперед!")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
            loadQuizzes()
    }
    
    

    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        quizzes.count
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var content = cell.defaultContentConfiguration()

        content.text = quizzes[indexPath.row].name
        content.textProperties.color = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        cell.contentConfiguration = content

        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            quizzes.remove(at: indexPath.row)
            QuizDataManager.shared.deleteQuizFromRealm(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       guard let quizVC =
               segue.destination as? QuizViewController else { return }
       guard let indexPath =
               tableView.indexPathForSelectedRow else { return }
        quizVC.quiz = quizzes[indexPath.row]
        quizVC.name = userName
    }
    
    @IBAction func quizUnwind(for unwindSeque: UIStoryboardSegue) {
    }
    
    private func loadQuizzes() {
        self.showActivityIndicator(target: self.navigationController ?? self, style: .large) { activityIndicator in
            activityIndicator.startAnimating()
            DispatchQueue.main.async {
                QuizDataManager.shared.loadQuizesFromRealm { [unowned self] quizes in
                    quizzes = quizes
                    activityIndicator.stopAnimating()
                    tableView.reloadData()
                }
            }
        }
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
