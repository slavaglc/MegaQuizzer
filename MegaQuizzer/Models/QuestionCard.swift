

import RealmSwift

class QuestionCard: EmbeddedObject {
    
    @Persisted var questionText: String = ""
    @Persisted var answers: List<Answer>
    
    convenience init(questionText: String = "", answers: [Answer]) {
        self.init()
        self.questionText = questionText
        self.answers.append(objectsIn: answers)
    }
    
    required override init() {
        super.init()
        
    }
    
}
