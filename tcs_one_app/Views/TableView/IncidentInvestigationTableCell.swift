//
//  IncidentInvestigationTableCell.swift
//  tcs_one_app
//
//  Created by TCS on 06/01/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import UIKit

class IncidentInvestigationTableCell: UITableViewCell {

    @IBOutlet weak var headingLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var detailTextView: UITextView!
    @IBOutlet weak var maxCounter: UILabel!
    @IBOutlet weak var word_counter: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        detailTextView.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
extension IncidentInvestigationTableCell: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.headingLabelTopConstraint.constant = 10
        self.headingLabel.font = UIFont.systemFont(ofSize: 11)
        self.headingLabel.textColor = UIColor.nativeRedColor()
        
//        switch textView.tag {
//        case ENTER_DETAIL_INVESTIGATION_TAG:
//            if textView.text == ENTER_DETAIL_INVESTIGATION {
//                textView.text = ""
//            }
//            break
//        default:
//            break
//        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        self.headingLabelTopConstraint.constant = 35
        self.headingLabel.font = UIFont.systemFont(ofSize: 15)
        self.headingLabel.textColor = UIColor.black
//        switch textView.tag {
//        case ENTER_DETAIL_INVESTIGATION_TAG:
//            if textView.text.count <= 0 {
//                textView.text = ENTER_DETAIL_INVESTIGATION
//            }
//            break
//        default:
//            break
//        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let maxLength = 200
        let currentString: NSString = textView.text as! NSString
        let newString: NSString =
                currentString.replacingCharacters(in: range, with: text) as NSString
        if newString.length <= maxLength {
            switch textView.tag {
            case ENTER_DETAIL_INVESTIGATION_TAG:
                self.word_counter.text = "\(newString.length)/200"
                return true
            default:
                return false
            }
        }
        return false
    }
}
