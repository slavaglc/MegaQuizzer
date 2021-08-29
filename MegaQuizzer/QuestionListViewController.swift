//
//  QuestionListViewController.swift
//  MegaQuizzer
//
//  Created by slava on 29.08.2021.
//

import UIKit

class QuestionListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var questions: [QuestionCard]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func addQuestionTapped(_ sender: UIButton) {
        
    }
    
}
