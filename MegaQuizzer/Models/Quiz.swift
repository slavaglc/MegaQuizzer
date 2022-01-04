
import RealmSwift
import Firebase

final class Quiz: Object {
    @Persisted(primaryKey: true) var id = ObjectId.generate()
    @Persisted var name: String = "" //Название викторины
    @Persisted var quizDescription: String?
    @Persisted var imagePath: String?
    @Persisted var questions: List<QuestionCard> //Объект из массива вопросов викторины
    @Persisted var user: AppUser?
    
    convenience init(name: String = "", questions: [QuestionCard]) {
        self.init()
        self.name = name
        self.questions.append(objectsIn: questions)
    }
    
    convenience init(snapshot: DataSnapshot) {
        self.init()
        let snapshotValue = snapshot.value as! [String: AnyObject]
        guard let questionsSnapshot = snapshotValue["questions"] as? [String: AnyObject] else { return }
        let quizDescription = snapshotValue["quizDescription"] as? String
        
        questionsSnapshot.forEach { questionCard in
            questions.append(QuestionCard(snapshotValue: questionCard.value))
        }
        name = snapshotValue["name"] as? String ?? "Unknow name"
        self.quizDescription = quizDescription
        
        }
         
    
    
    func convertToDictionary() -> Dictionary<String, String> {
        return ["id": id.stringValue, "name": name, "quizDescription": quizDescription ?? ""]
    }
 
}
