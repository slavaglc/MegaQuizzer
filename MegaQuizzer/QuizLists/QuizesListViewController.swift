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
        content.text = quizName
        content.textProperties.color = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        cell.contentConfiguration = content
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            guard let quizID = quizesStrings[indexPath.row].first?.key else { return }
            QuizDataManager.shared.deleteQuizFromRealm(by: quizID)
            quizesStrings.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       guard let quizStartVC =
               segue.destination as? QuizStartDisplayViewController else { return }
       guard let indexPath =
               tableView.indexPathForSelectedRow else { return }
        quizStartVC.quizID = !searchBegins ? quizesStrings[indexPath.row].first?.key : filtredQuizesStrings[indexPath.row].first?.key
        quizStartVC.locationType = .local
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
            searchBarItem.customView?.fadeInFromLeftSide()
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
            guard let user = AuthManager.shared.currentUserModel else { return }
            activityIndicator.startAnimating()
            DispatchQueue.main.async {
                QuizDataManager.shared.loadQuizesStrings(for: user) { [unowned self] fetchedStrings in
                    quizesStrings = fetchedStrings
                    activityIndicator.stopAnimating()
                    tableView.reloadData()
                }
            }
        }
    }
}
