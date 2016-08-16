//
//  PopoverMessage.swift
//  OvTijd
//
//  Created by Lars Stegman on 16-08-16.
//  Copyright © 2016 Stegman. All rights reserved.
//

import UIKit

@IBDesignable
class ScrollingMessages: UIView {

    var label = UILabel()
    private var leftLabelConstraint: NSLayoutConstraint! {
        didSet {
            initialLeftConstant = leftLabelConstraint.constant
        }
    }
    private var initialLeftConstant: CGFloat!
    private var scrollingTimer: NSTimer?

    var message: String? {
        didSet {
            label.text = message ?? " "
            label.sizeToFit()
            stopAnimating()
        }
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
        opaque = false
        backgroundColor = UIColor.clearColor()
        label.text = " "
        message = "No messages"
        label.textColor = UIColor.whiteColor()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        var labelYConstraints = [NSLayoutConstraint]()
        labelYConstraints.append(NSLayoutConstraint(item: label, attribute: .Top, relatedBy: .Equal, toItem: self,
            attribute: .TopMargin, multiplier: 1, constant: 0))
        labelYConstraints.append(NSLayoutConstraint(item: label, attribute: .Bottom, relatedBy: .Equal, toItem: self,
            attribute: .BottomMargin, multiplier: 1, constant: 0))
        leftLabelConstraint = NSLayoutConstraint(item: label, attribute: .Left, relatedBy: .Equal, toItem: self,
                                                 attribute: .LeftMargin, multiplier: 1, constant: 0)
        labelYConstraints.append(leftLabelConstraint)
        addSubview(label)
        NSLayoutConstraint.activateConstraints(labelYConstraints)
    }

    func startAnimating() {
        if !hidden
            && !animating
            && leftLabelConstraint != nil
            && initialLeftConstant != nil
            && label.frame.width > labelViewingSize.width {
            scrollText()
        }
    }

    func stopAnimating() {
        leftLabelConstraint?.constant = initialLeftConstant
        layoutIfNeeded()
        animating = false
    }

    var labelViewingSize: CGSize {
        return CGSize(width: bounds.width - layoutMargins.left - layoutMargins.right, height: label.frame.height)
    }

    /**
     The scrolling speed in points/s
     */
    var scrollSpeed = 60.0
    private var scrolledLeft = false
    private var animating = false

    func scrollText() {
        self.animating = true
        var newConstraintConstant: CGFloat
        var duration: Double
        if scrolledLeft {
            newConstraintConstant = initialLeftConstant
            duration = 1
        } else {
            let unshownLabelWidth = label.frame.width - labelViewingSize.width
            newConstraintConstant = initialLeftConstant - unshownLabelWidth
            duration = Double(unshownLabelWidth) / scrollSpeed
        }

        UIView.animateWithDuration(duration, animations: { [weak self] in
                self?.leftLabelConstraint.constant = newConstraintConstant
                self?.layoutIfNeeded()
            }, completion: { finished in
                let delay = self.scrolledLeft ? 1.0 : 3.0
                self.scrolledLeft = !self.scrolledLeft
                self.animating = false
                self.scrollingTimer = NSTimer.scheduledTimerWithTimeInterval(delay, target: self,
                    selector: #selector(ScrollingMessages.startAnimating), userInfo: nil, repeats: false)
            })
    }
}
