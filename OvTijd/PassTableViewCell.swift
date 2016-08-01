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
    @IBOutlet weak var deprecatedPassTimeLabel: UILabel!
    @IBOutlet weak var passTimeLabel: UILabel!

    var pass: Pass? {
        didSet {
            type = pass?.transportType
            lineId = pass?.lineDetails.publicNumber ?? ""

            direction = pass?.lineDetails.destinationName ?? ""
            if let planning = pass?.planning {
                currentPassTime = planning.expectedDeparture
                if abs(planning.expectedDeparture.timeIntervalSinceDate(planning.targetDepartureTime)) > 60 {
                    plannedPassTime = planning.targetDepartureTime
                }
            }
        }
    }

    private var type: Transport?            { didSet { updateUI() } }
    private var lineId: String = ""         { didSet { updateUI() } }
    private var plannedPassTime: NSDate?    { didSet { updateUI() } }
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
        typeLabel.text = lineId
        lineIcon.image = type?.generateIcon(forId: lineId)
        if let currPassTime = currentPassTime {
            passTimeLabel.text = dateFormatter.stringFromDate(currPassTime)
            if let tarDepartureTime = plannedPassTime {
                let plannedDepartureTimeLabelText = NSAttributedString(
                    string: dateFormatter.stringFromDate(tarDepartureTime),
                    attributes: [
                        NSStrikethroughStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue,
                        NSStrikethroughColorAttributeName: UIColor.redColor(),
                        NSForegroundColorAttributeName: UIColor.redColor()])
                deprecatedPassTimeLabel.attributedText = plannedDepartureTimeLabelText
            } else {
                deprecatedPassTimeLabel.text = ""
            }
        }

    }

}
