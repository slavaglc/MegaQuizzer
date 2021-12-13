//
//  RegistrationViewController.swift
//  MegaQuizzer
//
//  Created by Вячеслав Макаров on 12.12.2021.
//

import UIKit


final class RegistrationViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    private var activeTextField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @IBAction func registerButton(_ sender: UIButton) {
        guard let email = emailTextField.text, let password = passwordTextField.text, let confirmPassword = confirmPasswordTextField.text else { return }
        AuthManager.shared.signUp(email: email, password: password, confirmPassword: confirmPassword) { [weak self] error, success in
            if let error = error {
                self?.showAlert(title: "Ошибка регистрации", message: error, style: .alert)
            }
            
            if success {
                sender.isEnabled = false
                print("SUCCESS!!!!!")
            }
        }
    }
    
 
    
   @objc func keyboardWillShow(notification: NSNotification) {
       self.view.frame.origin.y = 0
       if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
           guard needToMoveView(for: keyboardSize) else { return }
               self.view.frame.origin.y -= keyboardSize.height
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
    }
    
    private func needToMoveView(for keyboardRect: CGRect) -> Bool {
        guard let activeTextField = activeTextField else { return false }
        let aRect = self.view.frame.height - keyboardRect.height
        let activeTFPoint = activeTextField.convert(activeTextField.frame, to: view)
        if activeTFPoint.maxY > aRect {
            return true
        }
        return false
    }
}

extension RegistrationViewController: UITextFieldDelegate {
   
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextField = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }

}
