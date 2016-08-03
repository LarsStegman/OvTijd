//
//  AnnotatedLabel.swift
//  OvTijd
//
//  Created by Lars Stegman on 02-08-16.
//  Copyright © 2016 Stegman. All rights reserved.
//

import UIKit

@IBDesignable
class AnnotatedLabel: UIView {

    @IBInspectable var labelText: String = "Label"                  { didSet { updateUI() } }
    @IBInspectable var labelColor: UIColor = UIColor.blackColor()   { didSet { updateUI() } }
    @IBInspectable var labelFontSize: CGFloat = 12                  { didSet { updateUI() } }
    
    @IBInspectable var valueColor: UIColor = UIColor.blackColor()   { didSet { updateUI() } }
    @IBInspectable var valueText: String = "Value"                  { didSet { updateUI() } }
    @IBInspectable var valueFontSize: CGFloat = 12                  { didSet { updateUI() } }
    
    @IBInspectable var separatorColor: UIColor = UIColor.lightGrayColor()    { didSet { updateUI() } }
    @IBInspectable var separatorMargin: CGFloat = 2                 { didSet { updateUI() } }
    @IBInspectable var separatorWidth: CGFloat = 1                  { didSet { updateUI() } }

    let labelLabel = UILabel()
    let valueLabel = UILabel()

    private func updateUI() {
        labelLabel.text = labelText.uppercaseString
        labelLabel.font = UIFont.systemFontOfSize(labelFontSize)
        labelLabel.textAlignment = .Natural
        labelLabel.textColor = labelColor

        valueLabel.text = valueText
        valueLabel.font = UIFont.systemFontOfSize(valueFontSize)
        valueLabel.textAlignment = .Center
        valueLabel.textColor = valueColor

        invalidateIntrinsicContentSize()
        setNeedsDisplay()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        addSubview(labelLabel)
        addSubview(valueLabel)
        var constraints = [NSLayoutConstraint]()

        constraints.append(NSLayoutConstraint(item: labelLabel, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: labelLabel, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1, constant: 0))


        constraints.append(NSLayoutConstraint(item: valueLabel, attribute: .Top, relatedBy: .Equal, toItem: labelLabel, attribute: .Bottom, multiplier: 1, constant: 2 * separatorMargin))
        constraints.append(NSLayoutConstraint(item: valueLabel, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: valueLabel, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1, constant: 0))

        NSLayoutConstraint.activateConstraints(constraints)
        labelLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.translatesAutoresizingMaskIntoConstraints = false

        updateUI()
    }

    override func intrinsicContentSize() -> CGSize {
        let labelSize = labelLabel.intrinsicContentSize()
        let valueSize = valueLabel.intrinsicContentSize()

        let width = max(labelSize.width, valueSize.width)
        let height = labelSize.height + valueSize.height + separatorMargin * 2
        return CGSize(width: width, height: height)
    }

    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        let bezier = UIBezierPath()
        var lineY = labelLabel.frame.origin.y + labelLabel.frame.height + separatorMargin
        if contentScaleFactor > 1.0 && contentScaleFactor % 2 == 0 {
            lineY -= 1 / (CGFloat(2) * contentScaleFactor)
        }
        bezier.moveToPoint(CGPoint(x: rect.origin.x, y: lineY))
        bezier.addLineToPoint(CGPoint(x: rect.origin.x + rect.width - 1 , y: lineY))
        bezier.lineWidth = separatorWidth / contentScaleFactor
        separatorColor.setStroke()
        bezier.stroke()
    }
    
}
