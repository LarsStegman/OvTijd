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

    private var label: UILabel? {
        if activeLabelIndex < labels.count && activeLabelIndex >= 0 {
            return labels[activeLabelIndex]
        }
        return nil
    }

    var activeLabelIndex = 0
    private var labels = [UILabel]()

    override var description: String {
        return super.description + "\n" + labels.map({ "\($0.description)\n" }).description
    }

    /**
     The message you want to display.
     
     - Important: If you change the message, the layout will be reset and animations stopped. Call `startAnimating` 
     again, to restart the animations.
     */
    var messages = [String]() {
        didSet {
            activeLabelIndex = 0
            updateLabels()
            resetLayout()
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
        clipsToBounds = true
        backgroundColor = UIColor.clearColor()
        messages = ["No messages"]
    }

    private func updateLabels() {
        labels.forEach({ $0.removeFromSuperview() })
        labels.removeAll()
        for i in 0..<messages.count {
            let label = UILabel()
            label.text = "\(i+1)/\(messages.count): \(messages[i])"
            label.textColor = UIColor.whiteColor()
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            labels.append(label)
        }
        setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        var previousFrame = CGRectZero
        for (index, label) in labels.enumerate() {
            label.sizeToFit()
            let y = previousFrame.origin.y + previousFrame.height + layoutMargins.top + CGFloat(index) * layoutMargins.bottom

            let frame = CGPoint(x: layoutMargins.left,
                                y: y)
            label.frame.origin = frame
            previousFrame = label.frame
        }
    }

    /**
     Starts the scrolling text animation.
     
     - Note: If the text of the label does not go out of bounds, the label will not be scrolled.
     */
    func startAnimating() {
        if label != nil && label!.frame.width > bounds.width - layoutMargins.left - layoutMargins.right {
            scrollHorizontally()
        }
    }

    /**
     Stops the animations and reset the label to the original position.
     */
    func stopAnimating() {
        resetLayout()
    }

    override func intrinsicContentSize() -> CGSize {
        if let label = label {
            return CGSize(width: label.frame.width,
                          height: label.frame.height + layoutMargins.top + layoutMargins.bottom)
        }
        return CGSizeZero
    }

    // MARK: Animation handling

    private struct AnimationIdentifiers {
        static let name = "name"
        static let scrollHorizontally = "scrollHorizontally"
        static let scrollToLeft = "scrollHorizontallyLeft"
        static let scrollToRight = "scrollHorizontallyRight"
        static let scrollVertically = "scrollVertically"
        static let labelIndex = "labelIndex"
    }

    private var scrollAnimationTimer: NSTimer?

    /**
     Resets the layout and removes animations.
     */
    private func resetLayout() {
        if let l = label {
            l.layer.removeAllAnimations()
            scrolledToRightOfLabel = false
            scrollAnimationTimer?.invalidate()

            l.sizeToFit()
            let labelLayer = l.layer
            labelLayer.position.x = layoutMargins.left + labelLayer.anchorPoint.x * labelLayer.bounds.width
        }

        layoutIfNeeded()
    }

    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        guard let name = anim.valueForKey(AnimationIdentifiers.name) as? String else {
            return
        }
        guard flag else {
            return
        }
        let index = anim.valueForKey(AnimationIdentifiers.labelIndex) as? Int
        var interval = 3.0
        var selector = #selector(ScrollingMessages.scrollHorizontally)

        switch name {
        case AnimationIdentifiers.scrollToRight:
            scrolledToRightOfLabel = true
            interval = 3
        case AnimationIdentifiers.scrollToLeft:
            scrolledToRightOfLabel = false
            interval = 1
            selector = #selector(ScrollingMessages.scrollToNextMessage)
        case AnimationIdentifiers.scrollVertically where index == activeLabelIndex:
            scrolledToRightOfLabel = false
            interval = 0.5
        default: return
        }
        print("New animation with selector \(selector)")
        scrollAnimationTimer = NSTimer.scheduledTimerWithTimeInterval(interval, target: self,
                                                                      selector: selector,
                                                                      userInfo: nil, repeats: false)
    }

    /**
     The scrolling speed in points/s
     */
    @IBInspectable var scrollSpeed = 60.0
    private var scrolledToRightOfLabel = false

    /**
     Scrolls the text across the screen.
     
     - Warning: Never call this method yourself, use `startAnimating` instead. Certain preconditions might not be 
     setup if you call this method yourself, leading to unexpected behaviour.
     - SeeAlso: `ScrollingMessages.startAnimating`
     */
    func scrollHorizontally() {
        guard let label = label else {
            return
        }
        let labelLayer = label.layer
        let from = labelLayer.position.x
        let to: CGFloat
        let duration: Double
        let timingFunction: CAMediaTimingFunction
        let id: String
        if scrolledToRightOfLabel { // Scroll to left
            to = layoutMargins.left + labelLayer.bounds.width * labelLayer.anchorPoint.x
            duration = 0.5
            timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            id = AnimationIdentifiers.scrollToLeft
        } else { // Scroll to left
            to = frame.width - layoutMargins.right - labelLayer.bounds.width * labelLayer.anchorPoint.x
            duration = Double(labelLayer.bounds.width) / scrollSpeed
            timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            id = AnimationIdentifiers.scrollToRight
        }

        let animation = CABasicAnimation(keyPath: "position.x")
        animation.fromValue = from
        animation.toValue = to
        animation.duration = duration
        animation.timingFunction = timingFunction
        animation.delegate = self
        animation.setValue(id, forKey: AnimationIdentifiers.name)

        labelLayer.position.x = to
        labelLayer.addAnimation(animation, forKey: id)
    }

    func scrollToNextMessage() {
        let newIndex = (activeLabelIndex + 1) % messages.count
        for (index, label) in labels.enumerate() {
            let anim = verticalAnimation(forLabelAt: index, activeIndexAfterAnimation: newIndex)
            label.layer.position.y = anim.toValue as! CGFloat
            label.layer.addAnimation(anim, forKey: AnimationIdentifiers.scrollVertically)
        }
        activeLabelIndex = newIndex
    }

    private func verticalAnimation(forLabelAt index: Int, activeIndexAfterAnimation: Int) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "position.y")

        let labelLayer = labels[index].layer
        let activeLabel = labels[activeIndexAfterAnimation]

        let to: CGFloat
        if index == activeIndexAfterAnimation {
            to = layoutMargins.top + activeLabel.layer.anchorPoint.y * activeLabel.frame.height
        } else if index < activeIndexAfterAnimation {
            var deltaY: CGFloat = 0
            for i in index+1..<activeIndexAfterAnimation {
                deltaY += layoutMargins.top + layoutMargins.bottom + labels[i].frame.height
            }
            deltaY += layoutMargins.bottom + (1-labelLayer.anchorPoint.y) * labels[index].frame.height
            to = -deltaY
        } else { // index > activeIndexAfterAnimation
            var deltaY: CGFloat = 0
            for i in activeIndexAfterAnimation..<index {
                deltaY += labels[i].layer.bounds.height + layoutMargins.top + layoutMargins.bottom
            }
            deltaY += layoutMargins.top + labelLayer.anchorPoint.y * labelLayer.bounds.height
            to = deltaY
        }

        animation.fromValue = labelLayer.position.y
        animation.toValue   = to
        animation.duration  = 0.5
        animation.delegate  = self
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)

        animation.setValue(index, forKey: AnimationIdentifiers.labelIndex)
        animation.setValue(AnimationIdentifiers.scrollVertically, forKey: AnimationIdentifiers.name)

        return animation
    }

}







