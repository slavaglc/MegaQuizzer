//
//  QuestionListViewController.swift
//  MegaQuizzer
//
//  Created by slava on 29.08.2021.
//

import UIKit

class QuestionListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var questions: [QuestionCard] = []
    var editingType: EditingType = .creating
    
    override func viewDidLoad() {
        super.viewDidLoad()
        questions = QuizDataManager.shared.currentCreatingCards
        tableView.reloadData()
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
