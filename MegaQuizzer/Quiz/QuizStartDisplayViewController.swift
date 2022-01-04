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
   var locationType: QuizLocationType!
   
    @IBOutlet weak var quizTitleLabel: UILabel!
    @IBOutlet weak var quizImageView: UIImageView!
    @IBOutlet weak var quizDescriptionLabel: UILabel!
   @IBOutlet weak var publishButton: UIButton!
   
    override func viewDidLoad() {
        super.viewDidLoad()
       loadQuiz()
    }
   
   override func viewDidAppear(_ animated: Bool) {
      setupImage()
   }
   
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      guard let quizVC =  segue.destination as? QuizViewController else { return }
      quizVC.quiz = quiz
   }
    
    @IBAction func startQuizButtonTapped(_ sender: UIButton) {
        sender.isEnabled = false
       performSegue(withIdentifier: "startQuizSegue", sender: nil)
    }
   
   @IBAction func publishQuizButtonTapped(_ sender: UIButton) {
      guard let user = AuthManager.shared.currentUser else { return
         
      }
      FirebaseManager.shared.saveQuizToFirebase(quiz: quiz, for: user)
   }
   
   
   private func setupGUI() {
      quizTitleLabel.text = quiz.name
      quizDescriptionLabel.text = quiz.quizDescription ?? ""
      
      switch locationType {
      case .network:
         publishButton.isHidden = true
      case .local:
         publishButton.isHidden = false
      case .none:
         publishButton.isHidden = true
      }
   }
   
   
   private func setupImage() {
      showActivityIndicator(target: self) { activityIdicator in
         guard let imagePath = quiz.imagePath else { return }
         activityIdicator.startAnimating()
         QuizDataManager.shared.loadImageFromLocalStore(by: imagePath) {  [weak self] image in
            guard let image = image else { activityIdicator.stopAnimating(); return }
            self?.quizImageView.image = image
            activityIdicator.stopAnimating()
            self?.quizImageView.fadeIn()
         }
      }
   }
   
   private func loadQuiz() {
      showActivityIndicator(target: self, style: .large) { activityIndicator in
         activityIndicator.startAnimating()
         QuizDataManager.shared.loadQuiz(id: quizID, from: locationType) { [weak self] fetchedQuiz in
            self?.quiz = fetchedQuiz
            self?.setupGUI()
            activityIndicator.stopAnimating()
         }
       }
   }
}
