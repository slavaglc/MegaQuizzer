//
//  PossibleAnswerTableViewCell.swift
//  MegaQuizzer
//
//  Created by slava on 31.07.2021.
//

import UIKit

class PossibleAnswerTableViewCell: UITableViewCell {
    @IBOutlet weak var possibleAnswerLabel: UILabel!
    @IBOutlet weak var truthSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
