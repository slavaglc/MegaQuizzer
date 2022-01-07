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
    
    func saveQuizToFirebase(quiz: Quiz , for user: User, completion: @escaping ()->() = {} ) {
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
            completion()
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
    
    func fetchQuizPreviewsFromFirebase(for user: User, completion: @escaping (_ quizesHeaders: [QuizPreview])->()) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let refQuiz = self?.refFB.child(user.uid).child("quizes") else { return }
            var quizPreviews = [QuizPreview]()
            refQuiz.observeSingleEvent(of: .value) { snapshot in
                 for item in snapshot.children {
                    if let item = item as? DataSnapshot {
                        guard let value = item.value as? [String: AnyObject] else { continue }
                        guard let firebaseID = value["firebaseID"] as? String, let name = value["name"] as? String, let realmID = value["id"] as? String else { continue }
                        quizPreviews.append(QuizPreview(firebaseID: firebaseID, realmID: realmID, name: name, imageURL: nil))
                    }
                }
                DispatchQueue.main.async {
                    completion(quizPreviews)
                }
            }
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
    
    func fetchQuizFromFirebase(user: User, by id: String, completion: @escaping (_ quiz: Quiz)->()) {
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
    
    func quizExistsInFirebase(for user: User, id: String) -> Bool {
        var result = false
        refFB.child(user.uid).child("quizes").observeSingleEvent(of: .value) { snapshot in
            guard let snapshotValue = snapshot.value as? [String: AnyObject] else { return }
            guard let idSnapshot = snapshotValue["id"] as? String else { return }
            result = idSnapshot == id
        }
        return result
    }
    
    func deleteQuizFromFirebase(for user: User, id: String, completion: @escaping ()->()) {
        let refToDelete = refFB.child(user.uid).child("quizes").child(id)
        refToDelete.removeValue { error, _ in
            if let error = error {
                print(error.localizedDescription)
            } else {
                completion()
            }
        }
    }
    
}
