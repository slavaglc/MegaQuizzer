//
//  FirebaseManager.swift
//  MegaQuizzer
//
//  Created by Вячеслав Макаров on 26.12.2021.
//

import Firebase


final class FirebaseManager {
    static let shared = FirebaseManager()

    var refFB: DatabaseReference!
    
    private init() {
        refFB = Database.database().reference(withPath: "users")
    }
    
    func saveQuizToFirebase(quiz: Quiz , for user: User) {
        let refQuiz = refFB.child(user.uid).child("quizes").childByAutoId()
        let firebaseID = refQuiz.key
        var quizDict = quiz.convertToDictionary()
        quizDict["firebaseID"] =  firebaseID
        refQuiz.setValue(quizDict) { error, ref in
            let questionsRef = ref.child("questions")
            quiz.questions.forEach { question in
                let questionRef = questionsRef.childByAutoId()
                let questionDict = question.convertToDictionary()
                questionRef.setValue(questionDict)
                question.answers.forEach { answer in
                    let answerRef = questionRef.child("answers").childByAutoId()
                    let answerDict = answer.convertToDictionary()
                    answerRef.setValue(answerDict)
                }
            }
        }
    }
    
    func fetchQuizHeadersFromFirebase(for user: User, completion: @escaping (_ quizesHeaders: [[String: String]])->()) {
        let refQuiz = refFB.child(user.uid).child("quizes")
        var quizesHeaders = Array<[String: String]>()
        refQuiz.observe(.value) { snapshot in
             for item in snapshot.children {
                if let item = item as? DataSnapshot {
                    guard let value = item.value as? [String: AnyObject] else { continue }
                    guard let id = value["firebaseID"] as? String, let name = value["name"] as? String else { continue }
                    quizesHeaders.append([id: name])
                }
            }
                completion(quizesHeaders)
        }
    }
    
    func fetchQuizesFromFirebase(for user: User, completion: @escaping (_ quizes: [Quiz])->()) {
        let refQuiz = refFB.child(user.uid).child("quizes")
        var quizes = [Quiz]()
        refQuiz.observe(.value) { snapshot in
            snapshot.children.forEach { item in
                if let item = item as? DataSnapshot {
                    let quiz = Quiz(snapshot: item)
                    quizes.append(quiz)
                }
            }
            completion(quizes)
        }
    }
    
    func fetchQuizFromFirebase(user: User ,by id: String, completion: @escaping (_ quiz: Quiz)->()) {
        let refQuiz = refFB.child(user.uid).child("quizes")
        refQuiz.observe(.value) { snapshot in
            snapshot.children.forEach { item in
                if let item = item as? DataSnapshot {
                    let quiz = Quiz(snapshot: item)
                    completion(quiz)
                }
            }
        }
    }
}
