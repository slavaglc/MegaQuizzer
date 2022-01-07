

import RealmSwift
import UIKit

final class QuizDataManager {
 
    static let shared = QuizDataManager()
    static let currentSchemaVersion: UInt64 = 7
    
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
            
            
            if oldSchemaVersion <= 6 {
                migrateFrom6To7(with: migration)
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
    
    static func migrateFrom6To7(with migration: Migration) {
        migration.enumerateObjects(ofType: Quiz.className()) { oldObject, newObject in
            newObject?["isPublished"] = false
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
    
    public func loadQuiz(id: String, from locationType: QuizLocationType, completion: @escaping (Quiz)->()) {
        
        switch locationType {
        case .network:
            guard let user = AuthManager.shared.currentUser else { break }

            FirebaseManager.shared.fetchQuizFromFirebase(user: user, by: id, completion: completion)
        case .local:
            loadQuizFromRealm(id: id, completion: completion)
        }
    }

    //    MARK: - Realm quiz methods
    public func loadQuizesStrings( completion: @escaping ([[String :String]])->()) {
        var quizStrings: [[String: String]] = []
        realm.objects(Quiz.self).forEach { quiz in
            quizStrings.append([quiz.id.stringValue: quiz.name])
        }
        completion(quizStrings)
    }
    
    public func loadQuizesHeaders(for user: AppUser, completion: @escaping ([[String :String]])->()) {
        var quizStrings: [[String: String]] = []
        user.quizes.forEach { quiz in
            quizStrings.append([quiz.id.stringValue: quiz.name])
        }
        completion(quizStrings)
    }
    
    public func loadQuizesFromRealm(completion: @escaping ([Quiz])->())  {
        var quizzesFromRealm: [Quiz] = []
        realm.objects(Quiz.self).forEach { quiz in
                quizzesFromRealm.append(quiz)
            }
            quizzes = quizzesFromRealm
            completion(quizzes)
    }
    
    public func loadQuizesFromRealm(for user: AppUser, completion: @escaping ([Quiz])->())  {
        var quizzesFromRealm: [Quiz] = []
        user.quizes.forEach { quiz in
                quizzesFromRealm.append(quiz)
            }
            quizzes = quizzesFromRealm
            completion(quizzes)
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
    
    public func getUserFromRealm(by uid: String) -> AppUser? {
        realm.object(ofType: AppUser.self, forPrimaryKey: uid)
    }
    
    public func createUser(user: AppUser) {
        try! realm.write {
            realm.add(user)
            }
    }
    
    public func quizExistsInRealmDB(quiz: Quiz) -> Bool {
        realm.object(ofType: Quiz.self, forPrimaryKey: quiz.id) != nil
    }
    
    public func quizExistsInRealmDB(id: String) -> Bool {
        guard let quizID = try? ObjectId(string: id) else { return false }
        return realm.object(ofType: Quiz.self, forPrimaryKey: quizID) != nil
    }
    
    public func quizIsPublished(quiz: Quiz) -> Bool? {
        realm.object(ofType: Quiz.self, forPrimaryKey: quiz.id)?.isPublished
    }
    
    
    public func setPublishedStatus(for id: String, status: Bool) {
        guard let quizID = try? ObjectId(string: id) else { return }
        guard let quiz = realm.object(ofType: Quiz.self, forPrimaryKey: quizID) else { return }
        do {
            try realm.write {
                quiz.isPublished = status
            }
        } catch(let error) {
            print(error.localizedDescription)
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
        guard let uid = user.uid else { return }
        guard let userFromRealm = getUserFromRealm(by: uid) else { return }
        try! realm.write {
            userFromRealm.quizes.append(quiz)
            quiz.user = userFromRealm
            realm.add(quiz, update: .modified)
        }
    }
    
    private func loadQuizFromRealm(id: String, completion: (Quiz)->()) {
        guard let quizID = try? ObjectId(string: id) else { return }
        guard let quiz = realm.object(ofType: Quiz.self, forPrimaryKey: quizID) else { return }
        completion(quiz)
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
        guard let uid = AuthManager.shared.currentUserModel?.uid else { return nil }
        let fileDirectory =  documentsDirectory.appendingPathComponent("users").appendingPathComponent(uid).appendingPathComponent("quizData").appendingPathComponent(id.stringValue).appendingPathComponent("previewImage").appendingPathComponent("PreviewImage.png", isDirectory: false)
        
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
