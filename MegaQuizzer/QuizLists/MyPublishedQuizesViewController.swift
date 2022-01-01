//
//  MyPublishedQuizesViewController.swift
//  MegaQuizzer
//
//  Created by Вячеслав Макаров on 31.12.2021.
//

import UIKit

class MyPublishedQuizesViewController: UITableViewController {
    
    var quizes = Array<Quiz>()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let user = AuthManager.shared.currentUser else { return }
        FirebaseManager.shared.fetchQuizesFromFirebase(for: user)
        { [weak self] quizes in
            print("fetched quiz", quizes)
            self?.quizes = quizes
            self?.tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quizes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyQuizesCell", for: indexPath)
        var content  = cell.defaultContentConfiguration()
        content.text = quizes[indexPath.row].name
        cell.contentConfiguration = content
        
        return cell
    }
}
