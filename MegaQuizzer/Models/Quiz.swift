//
//  Quiz.swift
//  MegaQuizzer
//
//  Created by Kristina Shlyapkina on 30.07.2021.
//

import RealmSwift

class Quiz: Object {
    
    @objc dynamic var name: String = "" //Название викторины
    let questions = List<QuestionCard>() //Объект из массива вопросов викторины
    
    internal init(name: String = "", questions: [QuestionCard]) {
        self.name = name
        self.questions.append(objectsIn: questions)
    }
    
    override class func primaryKey() -> String {
        return "name"
    }
    
    required override init() {
        super.init()
        
    }
    
}
