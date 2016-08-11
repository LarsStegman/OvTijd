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
            stopIndicator.type = pass.journeyDetails.stopType
            stopIndicator.passed = pass.status == .Arrived || pass.status == .Passed
        }

    }

}
