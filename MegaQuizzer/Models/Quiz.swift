
import RealmSwift

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

    
    required override init() {
        super.init()
    }
    
}
