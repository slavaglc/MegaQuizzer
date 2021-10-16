import UIKit

final class PossibleAnswerTableViewCell: UITableViewCell {
    @IBOutlet weak var possibleAnswerLabel: UILabel!
    @IBOutlet weak var truthSwitch: UISwitch!
    @IBOutlet weak var removeAnswerBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
