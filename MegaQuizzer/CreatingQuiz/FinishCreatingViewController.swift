//
//  FinishCreatingViewController.swift
//  MegaQuizzer
//
//  Created by Вячеслав Макаров on 06.11.2021.
//

import UIKit

final class FinishCreatingViewController: UIViewController {
    @IBOutlet weak var quizNameTextField: UITextField!
    @IBOutlet weak var previewLogoImageView: UIImageView!
    @IBOutlet weak var timerSwitch: UISwitch!
    @IBOutlet weak var attemptsSwitch: UISwitch!
    
    var questions: [QuestionCard] = []
    var quizName: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setGUI()
    }
    
    @IBAction func imageSelectionTapped() {
        showImagePicker()
    }
    
    
    private func setGUI() {
        previewLogoImageView.isHidden = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        quizNameTextField.text = quizName
    }
    
    @objc private func doneButtonTapped() {
        saveQuiz()
    }
    
    private func saveQuiz() {
        quizName = quizNameTextField.text
        guard quizName != "" else { return showAlert(title: "Ошибка!", message: "Введите название викторины!", style: .alert) }
        guard quizName.count < 50 else { return showAlert(title: "Длинное название!", message: "Вы выбрали слишком длинное название викторины. Название викторины должно содержать не более 50-ти символов", style: .alert) }
        QuizDataManager.shared.saveQuiz(quiz: Quiz(name: quizName, questions: questions))
        self.view.window!.rootViewController?.dismiss(animated: true, completion: nil)
        QuizDataManager.shared.currentCreatingCards.removeAll()
    }

}


extension FinishCreatingViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
   
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        previewLogoImageView.image = nil
        
        picker.dismiss(animated: true) { [unowned self] in
            previewLogoImageView.subviews.forEach { subview in
                subview.removeFromSuperview()
            }
            DispatchQueue.main.async {
            previewLogoImageView.image = image
            //previewLogoImageView.moveIn()
                previewLogoImageView.isHidden = false
            addRemoveImageButton()
            }
        }
    }
    
    
    private func showImagePicker() {
         let picker = UIImagePickerController()
         picker.delegate = self
         picker.allowsEditing = true
         picker.sourceType = .photoLibrary
         present(picker, animated: true)
     }
    
    private func addRemoveImageButton() {
//        xmark.bin.circle
        var removeImage: UIImage?
        if #available(iOS 15.0, *) {
            let config = UIImage.SymbolConfiguration(paletteColors: [.systemRed, .black, .white])
            removeImage = UIImage.init(systemName: "trash.circle.fill")?
                .withConfiguration(config)
            
        } else {
            
        }
        
        
        guard let removeImage = removeImage else { return }
        
        
        
        let btnPositionX = previewLogoImageView.contentClippingRect.width / 2
        let btnPositionY = previewLogoImageView.contentClippingRect.height / 2
        
        let removeButton = UIButton(frame: previewLogoImageView.contentClippingRect)
        print("imageView width:", previewLogoImageView.bounds.width)
        print("image width:", previewLogoImageView.contentClippingRect.width)
        
        removeButton.setImage(removeImage, for: .normal)
        
        
        
        
    
        previewLogoImageView.addSubview(removeButton)
    }
    
}
