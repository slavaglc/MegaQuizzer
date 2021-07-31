//
//  EnterViewController.swift
//  MegaQuizzer
//
//  Created by Максим on 30.07.2021.
//

import UIKit

class EnterViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var nameTextField: UITextField!

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let viewController =
                segue.destination as? UINavigationController else { return }
        guard let quizesListVC = viewController.viewControllers.first as? QuizesListViewController else { return }
        
        quizesListVC.userName = nameTextField.text
    }
    
    @IBAction func joinAction() {
        performSegue(withIdentifier: "segue", sender: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        joinAction()
        return true
    }

}
