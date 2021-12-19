//
//  User.swift
//  MegaQuizzer
//
//  Created by Вячеслав Макаров on 18.12.2021.
//

import RealmSwift


final class AppUser: Object {
    @Persisted(primaryKey: true) var uid: String?
    @Persisted var name: String?
    @Persisted var quizes: List<Quiz>
    
    convenience init(uid: String) {
        self.init()
        self.uid = uid
    }
}
