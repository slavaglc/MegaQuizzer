//
//  QuizManager.swift
//  MegaQuizzer
//
//  Created by Kristina Shlyapkina on 30.07.2021.
//

import RealmSwift

final class QuizDataManager {
 
    static let shared = QuizDataManager()
    static let currentSchemaVersion: UInt64 = 3
    
    private let realm = try! Realm()
    var currentCreatingCards: [QuestionCard] = []
    
    private var quizzes: [Quiz] = []

//    MARK: - Migration rules
    static func configureMigration() {
        let config = Realm.Configuration(schemaVersion: currentSchemaVersion, migrationBlock: { (migration, oldSchemaVersion) in
            if oldSchemaVersion < 1 {
                migrateFrom0To1(with: migration)
            }
         })
        Realm.Configuration.defaultConfiguration = config
    }
    
    static func migrateFrom0To1(with migration: Migration) {
               migration.enumerateObjects(ofType: Quiz.className()) {  (_, newQuizProperty) in
                       newQuizProperty?["imageURL"] = nil
                    }
                 }
//    MARK: - Quiz Methods
    public func saveQuiz(quiz: Quiz, withImage previewImage: UIImage? = nil) {
        quizzes.append(quiz)
        saveQuizToRealm(quiz: quiz, previewImage: previewImage)
    }
    
    public func getQuizzes(completion: @escaping ([Quiz])->()) -> [Quiz] {
            return quizzes
            }

   public func loadQuizesFromRealm(completion: @escaping ([Quiz])->())  {
        var quizzesFromRealm: [Quiz] = []
            realm.objects(Quiz.self).forEach { quiz in
                quizzesFromRealm.append(quiz)
            }
            quizzes = quizzesFromRealm
            completion(quizzes)
    }
    
    //    MARK: - Realm methods
   public func loadQuizesStrings(completion: @escaping ([[String :String]])->()) {
        var quizStrings: [[String: String]] = []
        realm.objects(Quiz.self).forEach { quiz in
            quizStrings.append([quiz.id.stringValue: quiz.name])
        }
        completion(quizStrings)
    }
    
    public func loadQuiz(id: String, completion: (Quiz)->()) {
        let quizID = try! ObjectId(string: id)
        guard let quiz = realm.object(ofType: Quiz.self, forPrimaryKey: quizID) else { return }
        completion(quiz)
    }

   public func deleteQuizFromRealm(at row: Int) {
       
        try! realm.write {
            realm.delete(realm.objects(Quiz.self)[row])
        }
    }
    
    public func deleteQuizFromRealm(by id: String) {
        guard let quizID = try? ObjectId(string: id) else { return }
        try! realm.write  {
            guard let object = realm.object(ofType: Quiz.self, forPrimaryKey: quizID) else { return }
            if let imageURL = object.imageURL {
                deleteImage(for: imageURL)
            }
            realm.delete(object)
        }
    }
    
    private func saveQuizToRealm(quiz: Quiz, previewImage: UIImage? = nil) {
        if let image = previewImage {
            guard let directory = getPreviewImageRelativePath(for: quiz.id) else { return }
            saveImage(imageName: "PreviewImage", image: image, directory: directory) { isFinished, path in
                if isFinished {
                    guard let imagePath = path else { return }
                    quiz.imageURL = imagePath
                }
            }
        }
        
        try! realm.write {
            realm.add(quiz, update: .all)
        }
    }
    
    private func saveImage(imageName: String, image: UIImage, directory: String, completion: @escaping (_ isFinished: Bool, _ url: String?)->()) {
        let fileName = imageName
        guard let documentsURL = getDocumentsDirectory() else { return }
        let fileURL = documentsURL.appendingPathComponent(directory).appendingPathComponent(fileName)
        
        guard let data = image.jpegData(compressionQuality: 0.7) else { return }

        //Checks if file exists, removes it if so.
      if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(atPath: fileURL.path)
                print("Removed old image")
            } catch let removeError {
                print("couldn't remove file at path:", removeError)
            }
        }

        do {
            try data.write(to: fileURL)
            completion(true, directory)
        } catch let error {
            print("error saving file with error:", error)
        }

    }
    
    private func deleteImage(for url: String) {
        guard let url = URL(string: url) else { return }
        do {
            try FileManager.default.removeItem(at: url)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    
    private func getPreviewImageRelativePath(for id: ObjectId) -> String? {
        
       guard let documentsDirectory = getDocumentsDirectory() else { return nil }
        
        let fileDirectory =  documentsDirectory.appendingPathComponent("users").appendingPathComponent("_USERNAME_").appendingPathComponent("quizData").appendingPathComponent(id.stringValue).appendingPathComponent("previewImage")
        
        do {
            try FileManager.default.createDirectory(atPath: fileDirectory.path, withIntermediateDirectories: true, attributes: nil)
            print("Directory created at:", fileDirectory)
        } catch let error as NSError {
            NSLog("Unable to create directory \(error.debugDescription)")
        }
        
        
        let resultPath = fileDirectory.pathComponents
                   .suffix(fileDirectory.pathComponents.count - documentsDirectory.pathComponents.count)
                   .joined(separator: "/")
               print(resultPath)
        
        return resultPath
    }
    
    private func getDocumentsDirectory() -> URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
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
