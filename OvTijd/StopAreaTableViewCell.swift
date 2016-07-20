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
    @IBOutlet weak var stopAreaTown: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!

    @IBOutlet weak var upcomingPassesStackView: UIStackView!
    
    var distance: Double? = Double.infinity {
        didSet {
            if let d = distance {
                distanceLabel.text = "\(Int(d))m"
            } else {
                distanceLabel.text = " "
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
