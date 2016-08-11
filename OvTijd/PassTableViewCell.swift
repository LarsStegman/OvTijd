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
    @IBOutlet weak var planningView: PlanningView!


    var pass: Pass? {
        didSet {
            type = pass?.transportType
            if let passData = pass {
                lineId = passData.lineDetails.publicNumber ?? ""
                direction = passData.lineDetails.destinationName ?? ""
                passed = passData.status == .Some(.Passed)
                planning = passData.planning
            }
            updateUI()
        }
    }

    private var type: Transport?
    private var lineId: String = ""
    private var direction: String = ""
    private var passed: Bool = false
    private var planning: PassPlanning?

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
        planningView.planning = planning
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
