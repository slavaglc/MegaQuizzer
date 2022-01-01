//
//  ResultViewController.swift
//  MegaQuizzer
//
//  Created by Максим on 31.07.2021.
//

import UIKit

final class ResultViewController: UIViewController {
    
    var userName: String?
    var result: Int?

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var resultLabel: UILabel!
    
    @IBOutlet var buttons: [UIButton]!

    override func viewDidLoad() {
        super.viewDidLoad()
        setButtonSettings()
        getData()
    }
    
    @IBAction func tryAgainTapped() {
        dismiss(animated: true)
    }
    
    
    private func setButtonSettings() {
        for button in buttons {
            button.layer.cornerRadius = button.frame.width / 10
        }
    }
    
    private func getData() {
        guard let userName = userName,
              let result = result else { return }

        nameLabel.text = "Поздравляем \(userName)!"
        resultLabel.text = "Вы получили \(result) очков!"
    }
}
