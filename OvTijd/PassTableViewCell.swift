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

    @IBOutlet weak var lineIdLabel: AnnotatedLabel!
    @IBOutlet weak var directionLabel: UILabel!
    @IBOutlet weak var deprecatedPassTimeLabel: UILabel!
    @IBOutlet weak var passTimeLabel: UILabel!

    var pass: Pass? {
        didSet {
            type = pass?.transportType
            if let passData = pass {
                lineId = passData.lineDetails.publicNumber ?? ""

                direction = passData.lineDetails.destinationName ?? ""
                passed = passData.status == .Some(.Passed)
                let planning = passData.planning
                currentPassTime = planning.expectedDepartureTime
                if abs(planning.expectedDepartureTime.timeIntervalSinceDate(planning.targetDepartureTime)) > 30 {
                    plannedPassTime = planning.targetDepartureTime
                }
            }
            updateUI()
        }
    }

    private var type: Transport?
    private var lineId: String = ""
    private var plannedPassTime: NSDate?
    private var currentPassTime: NSDate?
    private var direction: String = ""
    private var passed: Bool = false

    let dateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: "Europe/Amsterdam")
        dateFormatter.setLocalizedDateFormatFromTemplate("HH:mm")
        return dateFormatter
    }()

    private func updateUI() {
        directionLabel.text = direction
        directionLabel.enabled = !passed
        lineIdLabel.valueLabel.textAlignment = .Center
        lineIdLabel.valueText = lineId
        lineIdLabel.labelText = type?.rawValue ?? "Type"
        separatorInset.left = directionLabel.frame.origin.x
        
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

    private var baseLineLabelAndDirectionLabelEqual: NSLayoutConstraint?

    override func updateConstraints() {
        if let constraint = baseLineLabelAndDirectionLabelEqual {
            NSLayoutConstraint.deactivateConstraints([constraint])
        }

        baseLineLabelAndDirectionLabelEqual = NSLayoutConstraint(item: directionLabel, attribute: .FirstBaseline, relatedBy: .Equal, toItem: lineIdLabel.labelLabel, attribute: .FirstBaseline, multiplier: 1, constant: 0)
        NSLayoutConstraint.activateConstraints([baseLineLabelAndDirectionLabelEqual!])
        super.updateConstraints()
    }

}
