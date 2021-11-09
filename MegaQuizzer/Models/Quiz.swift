//
//  Quiz.swift
//  MegaQuizzer
//
//  Created by Kristina Shlyapkina on 30.07.2021.
//

import RealmSwift

class Quiz: Object {
    @Persisted(primaryKey: true) var id = ObjectId.generate()
    @Persisted var name: String = "" //Название викторины
    @Persisted var imagePath: String?
    @Persisted var questions: List<QuestionCard> //Объект из массива вопросов викторины
    
    convenience init(name: String = "", questions: [QuestionCard]) {
        self.init()
        self.name = name
        self.questions.append(objectsIn: questions)
    }

    
    required override init() {
        super.init()
        
    }
    
}
