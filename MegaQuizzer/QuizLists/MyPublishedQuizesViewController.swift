//
//  MyPublishedQuizesViewController.swift
//  MegaQuizzer
//
//  Created by Вячеслав Макаров on 31.12.2021.
//

import UIKit

final class MyPublishedQuizesViewController: UITableViewController {

    var quizPreviews = Array<QuizPreview>()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("Appeared")
        guard let user = AuthManager.shared.currentUser else { return }
        FirebaseManager.shared.fetchQuizPreviewsFromFirebase(for: user) {  [weak self] quizPreviews in
            self?.quizPreviews = quizPreviews
            print("count of quizPreviews:", quizPreviews.count)
            self?.tableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let quizStartVC =
                segue.destination as? QuizStartDisplayViewController else { return }
        guard let indexPath =
                tableView.indexPathForSelectedRow else { return }
        quizStartVC.quizID = quizPreviews[indexPath.row].firebaseID
         quizStartVC.locationType = .network
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        quizPreviews.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyQuizesCell", for: indexPath)
        var content  = cell.defaultContentConfiguration()
        content.text = quizPreviews[indexPath.row].name
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showMyPublishedQuizes", sender: nil)
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let firebaseID = quizPreviews[indexPath.row].firebaseID
            let realmID = quizPreviews[indexPath.row].realmID
            guard let user = AuthManager.shared.currentUser else { return }
            FirebaseManager.shared.deleteQuizFromFirebase(for: user, id: firebaseID) { [weak self] in
                self?.quizPreviews.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .left)
                QuizDataManager.shared.setPublishedStatus(for: realmID, status: false)
            }
        }
    }
    
}
