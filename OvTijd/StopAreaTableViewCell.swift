//
//  StopAreaTableViewCell.swift
//  OvTijd
//
//  Created by Lars Stegman on 14-07-16.
//  Copyright © 2016 Stegman. All rights reserved.
//

import UIKit

class StopAreaTableViewCell: UITableViewCell {

    @IBOutlet weak var stopAreaName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
