//
//  PurityCell.swift
//  Got Water
//
//  Created by Mitchell Gant on 3/29/17.
//  Copyright © 2017 Mitchell Gant. All rights reserved.
//

import UIKit

class PurityCell: UITableViewCell {
    
    
    
    
    
    @IBOutlet weak var overallConditionLabel: UILabel!
    @IBOutlet weak var virusPPMLabel: UILabel!
    @IBOutlet weak var contaminantPPMLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
