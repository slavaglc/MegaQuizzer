//
//  MyPublishedQuizesViewController.swift
//  MegaQuizzer
//
//  Created by Вячеслав Макаров on 31.12.2021.
//

import UIKit

final class MyPublishedQuizesViewController: UITableViewController {
        
    var quizesHeaders = Array<[String: String]>()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let user = AuthManager.shared.currentUser else { return }
        FirebaseManager.shared.fetchQuizHeadersFromFirebase(for: user) { [weak self] quizesHeaders in
            self?.quizesHeaders = quizesHeaders
            print(quizesHeaders)
            self?.tableView.reloadData()
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let quizStartVC =
                segue.destination as? QuizStartDisplayViewController else { return }
        guard let indexPath =
                tableView.indexPathForSelectedRow else { return }
         quizStartVC.quizID = quizesHeaders[indexPath.row].first?.key
         quizStartVC.locationType = .network
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quizesHeaders.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyQuizesCell", for: indexPath)
        var content  = cell.defaultContentConfiguration()
        content.text = quizesHeaders[indexPath.row].first?.value
        cell.contentConfiguration = content
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showMyPublishedQuizes", sender: nil)
    }
}
