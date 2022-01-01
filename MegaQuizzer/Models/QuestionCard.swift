

import RealmSwift

final class QuestionCard: EmbeddedObject {
    
    @Persisted var questionText: String = ""
    @Persisted var answers: List<Answer>
    
    convenience init(questionText: String = "", answers: [Answer]) {
        self.init()
        self.questionText = questionText
        self.answers.append(objectsIn: answers)
    }
    
    convenience init(snapshotValue: AnyObject ) {
        self.init()
        guard let questionText = snapshotValue["questionText"] as? String else { return }
        guard let answers = snapshotValue["answers"] as? [String: AnyObject] else { return }
                answers.forEach { answer in
                    self.answers.append(Answer(snapshotValue: answer.value))
                }
        self.questionText = questionText
    }
    
    func convertToDictionary() -> NSDictionary {
        return ["questionText": questionText]
    }
}
