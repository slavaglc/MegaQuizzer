//
//  NavigationController.swift
//  MegaQuizzer
//
//  Created by Вячеслав Макаров on 12.12.2021.
//

import UIKit
//import Firebase


final class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        try! Auth.auth().signOut()
        autoAuth()
    }
    
    private func autoAuth() {
        
        AuthManager.shared.autoAuth { [weak self] userIsSignedIn in
            if !userIsSignedIn {
                self?.performSegue(withIdentifier: "LoginVC", sender: nil)
            }
        }
    }
    
//    private func autoAuth(isLogged: Bool) {
//        if !isLogged {
//            self.performSegue(withIdentifier: "LoginVC", sender: nil)
//            guard let authListener = authListener else { return }
//            Auth.auth().removeStateDidChangeListener(authListener)
//        }
//    }
}
