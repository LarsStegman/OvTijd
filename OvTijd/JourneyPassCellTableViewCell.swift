//
//  JourneyPassCellTableViewCell.swift
//  OvTijd
//
//  Created by Lars Stegman on 06-08-16.
//  Copyright © 2016 Stegman. All rights reserved.
//

import UIKit
import OvTijdCore

class JourneyPassCellTableViewCell: UITableViewCell {

    @IBOutlet weak var stopNameLabel: UILabel!
    @IBOutlet weak var planningView: PlanningView!
    @IBOutlet weak var stopIndicator: StopIndicator!
    @IBOutlet weak var townLabel: UILabel!

    var pass: Pass? {
        didSet {
            updateUI()
        }
    }

    private func updateUI() {
        separatorInset.left = stopNameLabel.frame.origin.x
        if let pass = pass {
            stopNameLabel.text = pass.timingPoint.timingPointName
            planningView.planning = pass.planning
            townLabel.text = pass.timingPoint.timingPointTown
            stopIndicator.type = pass.stopType
            stopIndicator.passed = pass.status
        }
    }

    var baselineConstraints = [NSLayoutConstraint]()

    override func updateConstraints() {
        NSLayoutConstraint.deactivateConstraints(baselineConstraints)

        baselineConstraints.append(NSLayoutConstraint(item: stopNameLabel, attribute: .FirstBaseline, relatedBy: .Equal, toItem: planningView.currentDepartureTimeLabel, attribute: .FirstBaseline, multiplier: 1, constant: 0))

        NSLayoutConstraint.activateConstraints(baselineConstraints)

        super.updateConstraints()
    }

}
