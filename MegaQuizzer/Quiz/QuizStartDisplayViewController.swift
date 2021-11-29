//
//  QuizStartDisplayViewController.swift
//  MegaQuizzer
//
//  Created by Вячеслав Макаров on 25.11.2021.
//

import UIKit


class QuizStartDisplayViewController: UIViewController {
   
   var quizID: String!
   var quiz: Quiz!
   
    @IBOutlet weak var quizTitleLabel: UILabel!
    @IBOutlet weak var quizImageView: UIImageView!
    @IBOutlet weak var quizDescriptionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       loadQuiz()
    }
   
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      guard let quizVC =  segue.destination as? QuizViewController else { return }
      quizVC.quiz = quiz
   }
    
    @IBAction func startQuizButtonTapped(_ sender: UIButton) {
        sender.isEnabled = false
       performSegue(withIdentifier: "startQuizSegue", sender: nil)
    }
   
   private func setupGUI() {
      quizTitleLabel.text = quiz.name
      quizDescriptionLabel.text = quiz.quizDescription ?? ""
      setupImage()
   }
   
   private func setupImage() {
      guard let imagePath = quiz.imagePath else { return }
      
      QuizDataManager.shared.loadImageFromLocalStore(by: imagePath) {  [weak self] image in
         guard let image = image else { return }
         self?.quizImageView.image = image
         print(image)
      }
   }
   
   private func loadQuiz() {
       showActivityIndicator(target: self, style: .large) { activityIndicator in
           activityIndicator.startAnimating()
          QuizDataManager.shared.loadQuiz(id: quizID) { [weak self] fetchedQuiz in
              self?.quiz = fetchedQuiz
               activityIndicator.stopAnimating()
               setupGUI()
           }
       }
   }
   
}
