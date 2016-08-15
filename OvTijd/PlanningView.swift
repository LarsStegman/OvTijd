//
//  PlanningView.swift
//  OvTijd
//
//  Created by Lars Stegman on 06-08-16.
//  Copyright © 2016 Stegman. All rights reserved.
//

import UIKit
import OvTijdCore

@IBDesignable
class PlanningView: UIView {

    let stack: UIStackView
    let currentDepartureTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(16)
        label.textAlignment = .Right
        return label
    }()
    let plannedDepartureTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(14)
        label.textAlignment = .Right
        return label
    }()

    let df: NSDateFormatter = {
        let df = NSDateFormatter()
        df.dateFormat = "HH:mm"
        return df
    }()

    var planning: PassPlanning? {
        didSet {
            updateLabels()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        stack = UIStackView()
        super.init(coder: aDecoder)
        setup()
    }

    override init(frame: CGRect) {
        stack = UIStackView()
        super.init(frame: frame)
        setup()
    }

    private func setup() {
        stack.axis = .Vertical
        stack.addArrangedSubview(currentDepartureTimeLabel)
        stack.addArrangedSubview(plannedDepartureTimeLabel)
        addSubview(stack)
        updateLabels()

        var constraints = [NSLayoutConstraint]()
        constraints.append(NSLayoutConstraint(item: stack, attribute: .Top, relatedBy: .Equal, toItem: self,
            attribute: .Top, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: stack, attribute: .Trailing, relatedBy: .Equal, toItem: self,
            attribute: .Trailing, multiplier: 1, constant: 0))
        stack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activateConstraints(constraints)
    }

    private func updateLabels() {
        if let pl = planning {
            currentDepartureTimeLabel.text = df.stringFromDate(pl.expectedDepartureTime)
            if abs(pl.expectedDepartureTime.timeIntervalSinceDate(pl.targetDepartureTime)) > 60 {
                plannedDepartureTimeLabel.attributedText = NSAttributedString(string: df.stringFromDate(pl.targetDepartureTime), attributes: [
                    NSStrikethroughStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue,
                    NSStrikethroughColorAttributeName: UIColor.redColor(),
                    NSForegroundColorAttributeName: UIColor.redColor()])
            } else {
                plannedDepartureTimeLabel.text = ""
            }
        } else {
            currentDepartureTimeLabel.text = "10:09"
            plannedDepartureTimeLabel.text = "10:08"
        }
        invalidateIntrinsicContentSize()
    }

    override func intrinsicContentSize() -> CGSize {
        let plannedSize = plannedDepartureTimeLabel.intrinsicContentSize()
        let currentSize = currentDepartureTimeLabel.intrinsicContentSize()

        return CGSize(width: max(plannedSize.width, currentSize.width), height: plannedSize.height + currentSize.height)
    }
}
