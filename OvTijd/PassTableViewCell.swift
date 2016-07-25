//
//  PassTableViewCell.swift
//  OvTijd
//
//  Created by Lars Stegman on 22-07-16.
//  Copyright © 2016 Stegman. All rights reserved.
//

import UIKit
import OvTijdCore

class PassTableViewCell: UITableViewCell {

    @IBOutlet weak var lineIcon: UIImageView!
    @IBOutlet weak var directionLabel: UILabel!
    @IBOutlet weak var passTimeLabel: UILabel!

    var type: Transport?            { didSet { updateUI() } }
    var lineId: String = ""         { didSet { updateUI() } }
    var currentPassTime: NSDate?    { didSet { updateUI() } }
    var direction: String = ""      { didSet { updateUI() } }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    private func updateUI() {
        directionLabel.text = direction
        //lineIcon.image = Create icon from transport and lineId
        passTimeLabel.text = currentPassTime?.description
    }

}
