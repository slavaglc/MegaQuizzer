//
//  ResultViewController.swift
//  MegaQuizzer
//
//  Created by Максим on 31.07.2021.
//

import UIKit

class ResultViewController: UIViewController {
    
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    private func setButtonSettings() {
        for button in buttons {
            button.layer.cornerRadius = button.frame.width / 10
        }
    }
    
    private func getData() {
        guard let userName = userName,
              let result = result else { return }
//        
//        nameLabel.text = "Поздравляем Vfrcbv!"
//        resultLabel.text = "Вы получили 100 очков!"
        nameLabel.text = "Поздравляем \(userName)!"
        resultLabel.text = "Вы получили \(result) очков!"
    }
}
