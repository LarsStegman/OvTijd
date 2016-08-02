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
    @IBInspectable
    let labelLabel = UILabel()
    @IBInspectable
    let valueLabel = UILabel()

    @IBInspectable
    var labelText: String = "Label" {
        didSet {
            labelLabel.text = labelText.uppercaseString
            valueLabel.sizeToFit()
            setNeedsDisplay()
        }
    }
    @IBInspectable
    var valueText: String = "Value" {
        didSet {
            valueLabel.text = valueText
            valueLabel.sizeToFit()
            setNeedsDisplay()
        }
    }
    @IBInspectable
    var textColor: UIColor = UIColor.whiteColor() {
        didSet {
            labelLabel.textColor = textColor
            valueLabel.textColor = textColor
            setNeedsDisplay()
        }
    }
    @IBInspectable
    var lineColor: UIColor = UIColor.whiteColor()
    @IBInspectable
    var spaceBetweenLabelAndLine: CGFloat = 2

    override init(frame: CGRect) {
        super.init(frame: frame)
        labelLabel.text = labelText
        valueLabel.text = valueText
        labelLabel.textColor = textColor
        valueLabel.textColor = textColor
        addSubview(labelLabel)
        addSubview(valueLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        labelLabel.sizeToFit()
        valueLabel.sizeToFit()
        labelLabel.frame.origin = CGPoint(x: 0, y: 0)
        valueLabel.frame.origin = CGPoint(x: 0, y: labelLabel.frame.height + 2 * spaceBetweenLabelAndLine)
    }

    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        let bezier = UIBezierPath()
        let lineY = labelLabel.frame.height + spaceBetweenLabelAndLine
        bezier.moveToPoint(CGPoint(x: rect.origin.x, y: lineY))
        bezier.addLineToPoint(CGPoint(x: rect.origin.x + rect.width - 1 , y: lineY))
        bezier.lineWidth = 1
        lineColor.setStroke()
        bezier.stroke()
    }
    
}
