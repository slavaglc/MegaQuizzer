//
//  AuthManager.swift
//  MegaQuizzer
//
//  Created by Вячеслав Макаров on 12.12.2021.
//

import Firebase



final class AuthManager {
    
    static let shared = AuthManager()
    
    var currentUser: User?
    
    private init() {}
    
    func signIn(email: String, password: String, confirmPassword: String, completion: @escaping (_ error: String?, _ success: Bool) -> ()) {
        
        guard checkFields(email: email, password: password, confirmPassword: password, completion: completion) else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            self?.setCurrentUser(user: result, error: error, completion: completion)
        }
    }
    
    func signUp(email: String, password: String, confirmPassword: String?, completion: @escaping (_ error: String?, _ success: Bool) -> ()) {
        
        guard checkFields(email: email, password: password, confirmPassword: confirmPassword, completion: completion) else { return }
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            self?.setCurrentUser(user: result, error: error, completion: completion)
        }
    }
    
    private func checkFields(email: String, password: String, confirmPassword: String?, completion: @escaping (_ error: String?, _ success: Bool) -> ()) -> Bool {
        guard password == confirmPassword else { completion("Пароли не совпадают", false); return false}
        guard !email.isEmpty  else { completion("Введите адрес электронной почты", false); return false}
        guard !password.isEmpty else { completion("Введите пароль", false); return false }
        
        return true
    }
    
    private func setCurrentUser(user: AuthDataResult?, error: Error?, completion: @escaping (_ error: String?, _ success: Bool) -> ()) {
        if let error = error {
            completion(error.localizedDescription, false)
            return
        }
        
        if let user = user {
            currentUser = user.user
            completion(nil, true)
            return
        }
    }
}
