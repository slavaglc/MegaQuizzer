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
    
    private var quizesStrings: [[String: String]] = [], filtredQuizesStrings: [[String: String]] = [] //key - id, value - name
    private var searchBegins: Bool = false {
        didSet {
            tableView.reloadData()
        }
    }
    
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
        !searchBegins ? quizesStrings.count : filtredQuizesStrings.count
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var content = cell.defaultContentConfiguration()

        let quizName = !searchBegins ? quizesStrings[indexPath.row].first?.value : filtredQuizesStrings[indexPath.row].first?.value
        
        //content.text = !searchBegins ? quizzes[indexPath.row].name : filtredQuizzes[indexPath.row].name
        content.text = quizName
        content.textProperties.color = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        cell.contentConfiguration = content
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            //quizzes.remove(at: indexPath.row)
            quizesStrings.remove(at: indexPath.row)
            QuizDataManager.shared.deleteQuizFromRealm(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       guard let quizVC =
               segue.destination as? QuizViewController else { return }
       guard let indexPath =
               tableView.indexPathForSelectedRow else { return }
        quizVC.quizId = !searchBegins ? quizesStrings[indexPath.row].first?.key : filtredQuizesStrings[indexPath.row].first?.key
        //quizVC.quiz = !searchBegins ? quizzes[indexPath.row] : filtredQuizzes[indexPath.row]
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
           // searchBegins = true
            searchBar.becomeFirstResponder()
        }
    }
    
    @objc private func searchQuiz() {
        guard let searchBarText = searchBar.text else { return searchBegins.toggle()}
        let filtredQuizzes = quizesStrings.filter { quiz in
            guard let name = quiz.first?.value.lowercased() else { return false }
            return name.contains(searchBarText.lowercased())
        }
        
        self.filtredQuizesStrings = filtredQuizzes
        searchBegins = true
        
        if searchBarText.isEmpty {
            searchBegins = false
        }
        //tableView.reloadData()
    }
    
    private func loadQuizzes() {

        showActivityIndicator(target: self.navigationController ?? self, style: .large) { activityIndicator in
            activityIndicator.startAnimating()
            DispatchQueue.main.async {
                QuizDataManager.shared.loadQuizesStrings { [unowned self] fetchedStrings in
                    quizesStrings = fetchedStrings
                    activityIndicator.stopAnimating()
                    tableView.reloadData()
                }
            }
        }
    }
}
