//
//  RuleCell.swift
//  Call Control
//
//  Created by Kurtis Hill on 1/30/19.
//  Copyright © 2019 Kurtis Hill. All rights reserved.
//

import UIKit

class RuleCell: UITableViewCell {
    
    @IBOutlet weak var ruleLabel: UILabel!
    @IBOutlet weak var notesLabel: UILabel!
    @IBOutlet weak var activeSwitch: UISwitch!
    @IBOutlet weak var infoButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        ruleLabel.adjustsFontForContentSizeCategory = true
        notesLabel.adjustsFontForContentSizeCategory = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
