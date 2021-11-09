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
    
    var questions: [QuestionCard] = []
    var quizName: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setGUI()
    }
    
    @IBAction func imageSelectionTapped() {
        showImagePicker()
    }
    
    @objc private func doneButtonTapped() {
        saveQuiz()
    }
    
    private func setGUI() {
        previewLogoImageView.isHidden = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        quizNameTextField.text = quizName
    }
    
    
    
    private func saveQuiz() {
        quizName = quizNameTextField.text
        guard quizName != "" else { return showAlert(title: "Ошибка!", message: "Введите название викторины!", style: .alert) }
        guard quizName.count < 50 else { return showAlert(title: "Длинное название!", message: "Вы выбрали слишком длинное название викторины. Название викторины должно содержать не более 50-ти символов", style: .alert) }
        QuizDataManager.shared.saveQuiz(quiz: Quiz(name: quizName, questions: questions),withImage: previewLogoImageView.image)
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
            previewLogoImageView.moveIn()
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
        
        let removeButton = UIButton()
        var trashImage: UIImage?
        if #available(iOS 15.0, *) {
            let config = UIImage.SymbolConfiguration(paletteColors: [.systemRed, .black, .white])
            trashImage = UIImage.init(systemName: "trash.circle.fill")?
                .withConfiguration(config)
        } else {
            trashImage = UIImage(systemName: "trash.circle.fill")
            removeButton.tintColor = .systemRed
            removeButton.backgroundColor = .white
        }
        
        guard let trashImage = trashImage else { return }
        
        removeButton.frame.size = CGSize(width: 50, height: 50)
        
        let btnPositionX = previewLogoImageView.bounds.minX + removeButton.frame.width
        let btnPositionY = previewLogoImageView.bounds.maxY - removeButton.frame.height / 2
        
        removeButton.center = CGPoint(x: btnPositionX, y: btnPositionY)
        removeButton.contentMode = .center
        removeButton.setBackgroundImage(trashImage, for: .normal)
        removeButton.imageView?.contentMode = .scaleAspectFit
        removeButton.layer.cornerRadius = 0.5 * removeButton.bounds.size.width
        removeButton.clipsToBounds = true
        removeButton.addTarget(self, action: #selector(removeImage(sender:)), for: .touchUpInside)
        previewLogoImageView.addSubview(removeButton)
    }
    
    @objc private func removeImage(sender: UIButton) {
        sender.removeFromSuperview()
        previewLogoImageView.moveOut {
            self.previewLogoImageView.image = nil
        }
    }
    
}
