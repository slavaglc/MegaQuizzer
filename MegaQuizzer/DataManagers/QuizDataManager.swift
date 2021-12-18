

import RealmSwift
import UIKit

final class QuizDataManager {
 
    static let shared = QuizDataManager()
    static let currentSchemaVersion: UInt64 = 6
    
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
            
            if oldSchemaVersion <= 5 {
                migrateFrom5To6(with: migration)
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
    
    static func migrateFrom5To6(with migration: Migration) {
        migration.enumerateObjects(ofType: Quiz.className()) { oldObject, newObject in
            newObject?["user"] = nil
        }
    }
//    MARK: - Quiz Methods
    public func saveQuiz(quiz: Quiz, for user: AppUser? = nil, withImage previewImage: UIImage? = nil) {
        quizzes.append(quiz)
        saveQuizToRealm(quiz: quiz, for: user, previewImage: previewImage)
    }
    
    public func getQuizzes(completion: @escaping ([Quiz])->()) -> [Quiz] {
            return quizzes
            }

    public func loadQuizesFromRealm(for user: AppUser, completion: @escaping ([Quiz])->())  {
        var quizzesFromRealm: [Quiz] = []
        user.quizes.forEach { quiz in
                quizzesFromRealm.append(quiz)
            }
            quizzes = quizzesFromRealm
            completion(quizzes)
    }
    
    //    MARK: - Realm methods
    public func loadQuizesStrings(for user: AppUser, completion: @escaping ([[String :String]])->()) {
        var quizStrings: [[String: String]] = []
        user.quizes.forEach { quiz in
            quizStrings.append([quiz.id.stringValue: quiz.name])
        }
        completion(quizStrings)
    }
    
    public func loadQuiz(id: String, for user: AppUser, completion: (Quiz)->()) {
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
    
    private func saveQuizToRealm(quiz: Quiz, for user: AppUser? = nil, previewImage: UIImage? = nil) {
        if let image = previewImage {
            guard let imagePath = getPreviewImageRelativePath(for: quiz.id) else { return }
            saveImage(image: image, path: imagePath) { isFinished in
                if isFinished {
                    quiz.imagePath = imagePath
                }
            }
        }
        
        guard let user = user else { return }
        createUser(user: user)
        try! realm.write {
            user.quizes.append(quiz)
            quiz.user = user
            realm.add(quiz, update: .all)
        }
    }
    
    private func createUser(user: AppUser) {
        if realm.object(ofType: AppUser.self, forPrimaryKey: user.uid) == nil {
        try! realm.write {
            realm.add(user)
            }
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
