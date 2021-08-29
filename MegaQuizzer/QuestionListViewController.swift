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

        
    }
    

}

extension QuestionListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        questions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    
}
