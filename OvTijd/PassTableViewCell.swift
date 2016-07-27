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
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var passTimeLabel: UILabel!

    var pass: Pass? {
        didSet {
            type = pass?.transportType
            lineId = pass?.lineDetails.publicNumber ?? ""
            currentPassTime = pass?.planning.expectedDeparture
            direction = pass?.lineDetails.destinationName ?? ""
        }
    }

    private var type: Transport?            { didSet { updateUI() } }
    private var lineId: String = ""         { didSet { updateUI() } }
    private var currentPassTime: NSDate?    { didSet { updateUI() } }
    private var direction: String = ""      { didSet { updateUI() } }

    let dateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: "Europe/Amsterdam")
        dateFormatter.setLocalizedDateFormatFromTemplate("HH:mm")
        return dateFormatter
    }()

    private func updateUI() {
        directionLabel.text = direction
        typeLabel.text = "\(type?.rawValue ?? "" ) \(lineId)"
        lineIcon.image = type?.generateIcon(forId: lineId)
        if currentPassTime != nil {
            passTimeLabel.text = dateFormatter.stringFromDate(currentPassTime!)
        }
    }

}
