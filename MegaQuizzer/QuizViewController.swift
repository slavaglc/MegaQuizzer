//
//  QuizViewController.swift
//  MegaQuizzer
//
//  Created by Evgenii Efimov on 31.07.2021.
//

import UIKit

class QuizViewController: UIViewController {
    @IBOutlet weak var numberQuestionLabel: UILabel!
    @IBOutlet weak var quizName: UILabel!
    @IBOutlet weak var textQuestionsLabel: UILabel!
        
    @IBOutlet var answerButtonArray: [UIButton]!
    
    
    var quiz: Quiz!
    var name: String!
    var score = 0
    var scoreTrueAnswer = 100
    var scoreFalseAnswer = -50
    
    private var indexQuestions = 0
    private var arrayAnswerPerson: [UIButton] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingUI()
        data()
        numberAnswerText()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let resultVC = segue.destination as? ResultViewController else { return }
        resultVC.userName = name
        resultVC.result = score
    }
    
    @IBAction func answerButtonAction(_ sender: UIButton) {
        var countAnswerTrue = 0
        for answer in quiz.questions[indexQuestions].answers {
            if answer.isTrue == true {
                countAnswerTrue += 1
            }
        }
        if countAnswerTrue != 1 {
            sender.backgroundColor == UIColor.white ?
            (sender.backgroundColor = UIColor.yellow) :
            (sender.backgroundColor = UIColor.white)
        } else {
            settingDefaultButton()
            sender.backgroundColor == UIColor.white ?
            (sender.backgroundColor = UIColor.yellow) :
            (sender.backgroundColor = UIColor.white)
            }
        }

    @IBAction func nextButtonAction() {
            check()
            if arrayAnswerPerson.count == 0 {
                alertPresent()
            } else {
                settingUI()
                nextQuestions()
        }
   }
    private func settingDefaultButton() {
        for button in answerButtonArray {
            button.backgroundColor = UIColor.white
        }
    }
    
   private func settingUI() {
        for answerButton in answerButtonArray {
            answerButton.layer.cornerRadius = 10
            answerButton.isHidden = true
        }
    quizName.text = "Категория: \n\(quiz.name)"
        
    }
    
   private func data() {
        numberQuestionLabel.text = "Вопрос № - \(indexQuestions + 1)"
        textQuestionsLabel.text = quiz.questions[indexQuestions].questionText
        numberAnswerText()
            }
    
   private func numberAnswerText () {
        for (index,value) in quiz.questions[indexQuestions].answers.enumerated() {
            answerButtonArray[index].setTitle(value.answerText, for: .normal)
            answerButtonArray[index].isHidden = false
        }
    }
    
    private func nextQuestions() {
        if indexQuestions < quiz.questions.count - 1 {
            indexQuestions += 1
            arrayAnswerPerson.removeAll()
            data()
        } else {
            performSegue(withIdentifier: "ResultVC", sender: nil)
        }
    }
    private func alertPresent() {
        let alert = UIAlertController(title: "Ой-ой....",
                                      message:  "А ответ кто будет выбирать?",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Я",
                                      style: .default,
                                      handler: nil))
        self.present(alert,
                     animated: true,
                     completion: nil)
        }
    
    private func check() {
        for (index, value) in answerButtonArray.enumerated() {
            if value.backgroundColor == UIColor.yellow {
            arrayAnswerPerson.append(value)
            quiz.questions[indexQuestions].answers[index].isTrue ?
                (score += scoreTrueAnswer) : (score += scoreFalseAnswer)
                value.backgroundColor = UIColor.white
            }
        }
    }
}
