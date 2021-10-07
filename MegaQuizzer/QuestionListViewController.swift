//
//  QuestionListViewController.swift
//  MegaQuizzer
//
//  Created by slava on 29.08.2021.
//

import UIKit

final class QuestionListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var quizName: String = ""
    var questions: [QuestionCard] = []
    var editingType: EditingType = .creating
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setGUI()
        questions = QuizDataManager.shared.currentCreatingCards
        tableView.reloadData()
    }
    
    private func setGUI() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(saveQuiz))
    }
    
    @objc private func saveQuiz() {
        guard questions.count > 0 else { return showAlert(title: "Постойте!", message: "Вы не создали ни одного вопроса", style: .alert) }

        QuizDataManager.shared.saveQuiz(quiz: Quiz(name: quizName, questions: questions))
        self.view.window!.rootViewController?.dismiss(animated: true, completion: nil)
        QuizDataManager.shared.currentCreatingCards.removeAll()
    }
}

extension QuestionListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        questions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "questionCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = questions[indexPath.row].questionText
        content.secondaryText = "Количество ответов: " + String(questions[indexPath.row].answers.count)
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        editingType = .editing(index: indexPath.row)
        self.performSegue(withIdentifier: "unwindToCreating", sender: self)
    }
    
    
}
