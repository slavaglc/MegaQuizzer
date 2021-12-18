
import RealmSwift

final class Answer: EmbeddedObject {
    
    @Persisted var answerText: String = "" //Текст ответа
    @Persisted var isTrue: Bool = false //Здесь правильность ответа отслеживается
    
    internal init(answerText: String = "", isTrue: Bool = false) {
        self.answerText = answerText
        self.isTrue = isTrue
    }
    
    required override init() {
        super.init()
    }
}
