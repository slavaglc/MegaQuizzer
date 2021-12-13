//
//  NavigationController.swift
//  MegaQuizzer
//
//  Created by Вячеслав Макаров on 12.12.2021.
//

import UIKit
import Firebase


final class NavigationController: UINavigationController {
    
    var userIsLogged: Bool = false
    var authListener: AuthStateDidChangeListenerHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        autoAuth(isLogged: userIsLogged)
    }
    
    func autoAuth(isLogged: Bool) {
        if !isLogged {
            self.performSegue(withIdentifier: "LoginVC", sender: nil)
//            Auth.auth().removeStateDidChangeListener(authListener!)
        }
    }
    
}
