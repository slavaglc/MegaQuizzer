//
//  QuizesListTableTableViewController.swift
//  MegaQuizzer
//
//  Created by Максим on 30.07.2021.
//

import UIKit

final class QuizesListViewController: UITableViewController {
    
    var userName: String?
    lazy private  var searchBar: UISearchBar = {
        let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: 200, height: 20))
        let textField = searchBar.value(forKey: "searchField") as? UITextField
        searchBar.placeholder = "Поиск викторины"
        searchBar.tintColor = .white
        textField?.backgroundColor = .orange
        return searchBar
    }()
    private var quizzes: [Quiz] = []
    private var filtredQuizzes: [Quiz] = []
    private var searchBegins = false
    
    //[Quiz(name: "test", questions: [QuestionCard(questionText: "", answers: [Answer(answerText: "", isTrue: true)])])]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // guard let userName = userName else { return }
        setGUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
            loadQuizzes()
    }
    
    

    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        !searchBegins ? quizzes.count : filtredQuizzes.count
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var content = cell.defaultContentConfiguration()

        content.text = !searchBegins ? quizzes[indexPath.row].name : filtredQuizzes[indexPath.row].name
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
    
    private func setGUI() {
        let button = UIButton()
        button.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(showSearchButtonPressed(sender:)), for: .touchUpInside)
        let searchButton = UIBarButtonItem(customView: button)
        navigationItem.rightBarButtonItems?.append(searchButton)
        searchBar.searchTextField.addTarget(self, action: #selector(searchQuiz), for: .editingChanged)
        
        navigationItem.leftBarButtonItem = editButtonItem
        navigationItem.leftBarButtonItem?.tintColor = .white
    }
    
    
    @objc private func showSearchButtonPressed(sender: UIButton) {
        switch sender.tag {
        case 0: //search
            DispatchQueue.main.async {
                showSearchBar()
            }
            sender.tag = 1
            break
       default: //cancel
            navigationItem.leftBarButtonItem = editButtonItem
            searchBar.endEditing(false)
            sender.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
            sender.tag = 0
            searchBegins = false
            break
        }
        
        func showSearchBar() {
            let searchBarItem = UIBarButtonItem(customView:searchBar)
            searchBarItem.customView?.fadeIn()
            self.navigationItem.leftBarButtonItem = searchBarItem
            sender.setImage(UIImage(systemName: "xmark"), for: .normal)
            searchBegins = true
            searchBar.becomeFirstResponder()
        }
    }
    
    @objc private func searchQuiz() {
        searchBegins = true
        let filtredQuizzes = quizzes.filter{ quiz in
            quiz.name.lowercased().contains(searchBar.text!.lowercased()) }
        self.filtredQuizzes = filtredQuizzes
        guard let text = searchBar.text else { return searchBegins.toggle()}
        
        if text.isEmpty {
            searchBegins = false
        }
       tableView.reloadData()
    }
    
    private func loadQuizzes() {
        showActivityIndicator(target: self.navigationController ?? self, style: .large) { activityIndicator in
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
