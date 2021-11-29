

import RealmSwift
import UIKit

final class QuizDataManager {
 
    static let shared = QuizDataManager()
    static let currentSchemaVersion: UInt64 = 5
    
    private let realm = try! Realm()
    var currentCreatingCards: [QuestionCard] = []
    
    private var quizzes: [Quiz] = []

    private init() {
    }
    
//    MARK: - Migration rules
    static func configureMigration() {
        let config = Realm.Configuration(schemaVersion: currentSchemaVersion, migrationBlock: { (migration, oldSchemaVersion) in
            if oldSchemaVersion < 1 {
                migrateFrom0To1(with: migration)
            }
            
            if oldSchemaVersion == 3 {
             migrateFrom3To4(with: migration)
            }
            
            if oldSchemaVersion == 4 {
                migrateFrom4To5(with: migration)
            }
         })
        Realm.Configuration.defaultConfiguration = config
    }
    
    static func migrateFrom0To1(with migration: Migration) {
               migration.enumerateObjects(ofType: Quiz.className()) {  (_, newQuizProperty) in
                       newQuizProperty?["imageURL"] = nil
                    }
                 }
    static func migrateFrom3To4(with migration: Migration) {
        migration.renameProperty(onType: Quiz.className(), from: "imageURL", to: "imagePath")
    }
    
    static func migrateFrom4To5(with migration: Migration) {
        migration.enumerateObjects(ofType: Quiz.className()) { oldObject, newQuizProperty in
            newQuizProperty?["quizDescription"] = nil
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
            if let imageURL = object.imagePath {
                deleteImage(for: imageURL)
            }
            realm.delete(object)
        }
    }
    //MARK: - Realm Image Methods
    public func loadImageFromLocalStore(by relativePath: String, completion: @escaping (UIImage?)->()) {
        
        guard let url = getPreviewImageFullPath(by: relativePath) else { return }
        let fileURL = URL(fileURLWithPath: url.path)
        var image: UIImage?
        DispatchQueue.global(qos: .userInitiated).async {
            image = UIImage(contentsOfFile: fileURL.path)
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
    
    private func saveQuizToRealm(quiz: Quiz, previewImage: UIImage? = nil) {
        if let image = previewImage {
            guard let imagePath = getPreviewImageRelativePath(for: quiz.id) else { return }
            saveImage(image: image, path: imagePath) { isFinished in
                if isFinished {
                    quiz.imagePath = imagePath
                }
            }
        }
        
        try! realm.write {
            realm.add(quiz, update: .all)
        }
    }
    
    private func saveImage(image: UIImage, path: String, completion: @escaping (_ isFinished: Bool)->()) {
        guard let documentsURL = getDocumentsDirectory() else { return }
        let fileURL = documentsURL.appendingPathComponent(path)
        guard let data = image.jpegData(compressionQuality: 0.7) else { return }
        

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
            completion(true)
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
        
        let fileDirectory =  documentsDirectory.appendingPathComponent("users").appendingPathComponent("_USERNAME_").appendingPathComponent("quizData").appendingPathComponent(id.stringValue).appendingPathComponent("previewImage").appendingPathComponent("PreviewImage.png", isDirectory: false)
        
        do {
            try FileManager.default.createDirectory(atPath: fileDirectory.path, withIntermediateDirectories: true, attributes: nil)
            print("Directory created at:", fileDirectory)
        } catch let error as NSError {
            NSLog("Unable to create directory \(error.debugDescription)")
        }
        
        let relativePath = fileDirectory.pathComponents
                   .suffix(fileDirectory.pathComponents.count - documentsDirectory.pathComponents.count)
                   .joined(separator: "/")
               print(relativePath)
        
        return relativePath
    }
    
    private func getPreviewImageFullPath(for id: ObjectId) -> URL? {
         getDocumentsDirectory()?.appendingPathComponent(getPreviewImageRelativePath(for: id) ?? "") ?? nil
    }
    
    private func getPreviewImageFullPath(by stringPath: String) -> URL? {
        getDocumentsDirectory()?.appendingPathComponent(stringPath) ?? nil
    }
    
    private func getDocumentsDirectory() -> URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    

    
}
