//
//  QuestionCard.swift
//  MegaQuizzer
//
//  Created by Kristina Shlyapkina on 30.07.2021.
//

import RealmSwift

class QuestionCard: Object {
    
    @objc dynamic var questionText: String = ""
     var answers = List<Answer>()
    
    internal init(questionText: String = "", answers: [Answer]) {
        self.questionText = questionText
        self.answers.append(objectsIn: answers)
    }
    
    required override init() {
        super.init()
        
    }
    
}
