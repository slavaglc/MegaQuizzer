//
//  LoginViewController.swift
//  MegaQuizzer
//
//  Created by Вячеслав Макаров on 12.12.2021.
//

import UIKit


final class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        signIn()
    }
    
    private func signIn() {
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
        AuthManager.shared.signIn(email: email, password: password, confirmPassword: password) { [weak self] error, success in
            if let error = error {
                self?.showAlert(title: "Ошибка входа", message: error, style: .alert)
            }
            guard success else { return }
            print("SUCCESS!!!!!")
        }
    }
    
}
