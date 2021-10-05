//
//  Answer.swift
//  MegaQuizzer
//
//  Created by Kristina Shlyapkina on 30.07.2021.
//


import RealmSwift

class Answer: Object {
    
    @objc dynamic var answerText: String = "" //Текст ответа
    @objc dynamic var isTrue: Bool = false //Здесь правильность ответа отслеживается
    
    internal init(answerText: String = "", isTrue: Bool = false) {
        self.answerText = answerText
        self.isTrue = isTrue
    }
    
    required override init() {
        super.init()
    }
}
