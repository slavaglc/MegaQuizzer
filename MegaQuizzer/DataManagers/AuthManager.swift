//
//  AuthManager.swift
//  MegaQuizzer
//
//  Created by Вячеслав Макаров on 12.12.2021.
//

import Firebase



final class AuthManager {
    
    static let shared = AuthManager()
    
    var currentUserModel: AppUser?
    var currentUser: User?
    var ref: DatabaseReference!
    
    private var userIsLogged: Bool = false
    private var authListener: AuthStateDidChangeListenerHandle?
    
    private init() {
        ref = Database.database().reference(withPath: "users")
    }
    
    func signIn(email: String, password: String, confirmPassword: String, completion: @escaping (_ error: String?, _ success: Bool) -> ()) {
        
        guard checkFields(email: email, password: password, confirmPassword: password, completion: completion) else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            self?.setCurrentUser(user: result?.user, error: error, completion: completion)
        }
    }
    
    func signUp(email: String, password: String, confirmPassword: String?, name: String, completion: @escaping (_ error: String?, _ success: Bool) -> ()) {
        
        guard checkFields(email: email, password: password, confirmPassword: confirmPassword, completion: completion) else { return }
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            
            guard let user = result?.user else { return }
           
            guard let userRef = self?.ref.child(user.uid) else { return }
            userRef.setValue(["UID": user.uid, "Email": user.email, "Name": name])
            
            self?.setCurrentUser(user: user, name: name, error: error, completion: completion)
        }
    }
    
    func autoAuth(completion: @escaping (_ userIsSignedIn: Bool)->()) {
        let group = DispatchGroup()
        authListener = Auth.auth().addStateDidChangeListener{ [weak self] (auth, user) in
            group.enter()
            if user != nil {
                self?.userIsLogged = true
                self?.setCurrentUser(user: user)
            } else {
                self?.userIsLogged = false
            }
            completion(self?.userIsLogged ?? false)
            group.leave()
        }
        group.notify(queue: .main) { [weak self] in
            guard let authListener = self?.authListener else { return }
            Auth.auth().removeStateDidChangeListener(authListener)
        }
    }
    
    
    private func checkFields(email: String, password: String, confirmPassword: String?, completion: @escaping (_ error: String?, _ success: Bool) -> ()) -> Bool {
        guard password == confirmPassword else { completion("Пароли не совпадают", false); return false}
        guard !email.isEmpty  else { completion("Введите адрес электронной почты", false); return false}
        guard !password.isEmpty else { completion("Введите пароль", false); return false }
        
        return true
    }
    
    private func setCurrentUser(user: User?, name: String? = nil, error: Error? = nil, completion: @escaping ((_ error: String?, _ success: Bool) -> ()) = {error,success in }) {
        if let error = error {
            completion(error.localizedDescription, false)
            return
        }
        
        if let user = user {
            currentUser = user
            currentUserModel = QuizDataManager.shared.getUserFromRealm(by: user.uid)
            if currentUserModel == nil {
                QuizDataManager.shared.createUser(user: AppUser(uid: user.uid))
                currentUserModel = QuizDataManager.shared.getUserFromRealm(by: user.uid)
            }
            completion(nil, true)
            return
        }
    }
}
