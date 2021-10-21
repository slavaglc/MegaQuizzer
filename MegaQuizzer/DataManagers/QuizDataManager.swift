//
//  QuizManager.swift
//  MegaQuizzer
//
//  Created by Kristina Shlyapkina on 30.07.2021.
//

import RealmSwift

final class QuizDataManager {
 
    static let shared = QuizDataManager()
    let realm = try! Realm()
    var currentCreatingCards: [QuestionCard] = []
    
    //private var realm = try! Realm()
    //private let realmConfig: Realm.Configuration  =
    private var quizzes: [Quiz] = []

    
    func saveQuiz(quiz: Quiz) {
        quizzes.append(quiz)
        saveQuizToRealm(quiz: quiz)
    }
    
    func getQuizzes(completion: @escaping ([Quiz])->()) -> [Quiz] {
            return quizzes
            }

    func loadQuizesFromRealm(completion: @escaping ([Quiz])->())  {
        var quizzesFromRealm: [Quiz] = []
            realm.objects(Quiz.self).forEach { quiz in
                quizzesFromRealm.append(quiz)
            }
            quizzes = quizzesFromRealm
            completion(quizzes)
    }
    
    func loadQuizesStrings(completion: @escaping ([[String :String]])->()) {
        var quizStrings: [[String: String]] = []
        realm.objects(Quiz.self).forEach { quiz in
            quizStrings.append([quiz.id.stringValue: quiz.name])
        }
        completion(quizStrings)
    }
    
    func loadQuiz(id: String, completion: (Quiz)->()) {
        let quizID = try! ObjectId(string: id)
        guard let quiz = realm.object(ofType: Quiz.self, forPrimaryKey: quizID) else { return }
        completion(quiz)
    }
    
    func deleteQuizFromRealm(at row: Int) {
        try! realm.write {
            realm.delete(realm.objects(Quiz.self)[row])
        }
    }

    private func saveQuizToRealm(quiz: Quiz) {
            try! realm.write {
                realm.add(quiz, update: .all)
            }
    }
    
    private init() {
//        quizzes.append(
//            Quiz(name: "Кино",
//                 questions:
//                    [
//                        QuestionCard(questionText: "В каком веке был изобретен кинематограф?",
//                                     answers: [
//                                        Answer(answerText: "В XVII веке", isTrue: false),
//                                        Answer(answerText: "В XIX веке", isTrue: true),
//                                        Answer(answerText: "В XX веке", isTrue: false)
//                                     ]),
//
//                        QuestionCard(questionText: "Что изначально отсутствовало в кинофильмах?",
//                                     answers: [
//                                        Answer(answerText: "Звук", isTrue: true),
//                                        Answer(answerText: "Актеры", isTrue: false),
//                                        Answer(answerText: "Сюжет", isTrue: false)
//                                     ]),
//
//                        QuestionCard(questionText: "Как назывался первый цветной фильм, раскрашенный вручную?",
//                                     answers: [
//                                        Answer(answerText: "Кинемаколор", isTrue: false),
//                                        Answer(answerText: "Путешествие на луну", isTrue: true),
//                                        Answer(answerText: "Змеиный танец", isTrue: false)
//                                     ]),
//
//                        QuestionCard(questionText: "Какова была средняя длина фильмов в начале XX века?",
//                                     answers: [
//                                        Answer(answerText: "15 минуты", isTrue: true),
//                                        Answer(answerText: "3 минуты", isTrue: false),
//                                        Answer(answerText: "1 час", isTrue: false)
//                                     ]),
//
//                        QuestionCard(questionText: "В каком году был снят первый российский цветной кинофильм?",
//                                     answers: [
//                                        Answer(answerText: "1907", isTrue: false),
//                                        Answer(answerText: "1913", isTrue: false),
//                                        Answer(answerText: "1931", isTrue: true)
//                                     ]),
//
//                        QuestionCard(questionText: "Что характерно для немого кино?",
//                                     answers: [
//                                        Answer(answerText: "Отсутствие диалогов в сюжете", isTrue: false),
//                                        Answer(answerText: "Отсутствие звуковой дорожки с речью актеров", isTrue: true),
//                                        Answer(answerText: "Полное отсутствие звуковой дорожки", isTrue: false)
//                                     ])
//                    ]))
    }
    
    
    
}
