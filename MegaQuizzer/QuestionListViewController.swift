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
        content.secondaryText = String(questions[indexPath.row].answers.count)
        cell.contentConfiguration = content
        return cell
    }
    
    
}
