//
//  StopIndicator.swift
//  OvTijd
//
//  Created by Lars Stegman on 08-08-16.
//  Copyright © 2016 Stegman. All rights reserved.
//

import UIKit
import OvTijdCore

@IBDesignable
class StopIndicator: UIView {
    var type: JourneyStopType = .First {
        didSet {
            cachedPath = nil
            setNeedsDisplay()
        }
    }
    var passed = true {
        didSet {
            cachedPath = nil
            setNeedsDisplay()
        }
    }

    @IBInspectable var lineWidth: CGFloat = 2
    @IBInspectable var lineColor: UIColor = UIColor.yellowColor()
    @IBInspectable var circleRadius: CGFloat = 10

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    private func setup() {
        opaque = false
    }

    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        let context = UIGraphicsGetCurrentContext()
        CGContextSaveGState(context)

        if passed {
            CGContextAddPath(context, indicatorPath)
            CGContextSetFillColorWithColor(context, lineColor.CGColor)
            CGContextFillPath(context)
        }

        CGContextAddPath(context, indicatorPath)
        CGContextSetStrokeColorWithColor(context, lineColor.CGColor)
        CGContextSetLineWidth(context, lineWidth)
        CGContextStrokePath(context)
    }

    private var cachedPath: CGPath?
    var indicatorPath: CGPath {
        if let path = cachedPath {
            return path
        }
        let path = CGPathCreateMutable()

        let circleRect = rectForCircle()
        CGPathAddEllipseInRect(path, nil, circleRect)
        let lines = linesFor(type, circleBounds: circleRect)
        for (start, end) in lines {
            CGPathMoveToPoint(path, nil, start.x, start.y)
            CGPathAddLineToPoint(path, nil, end.x, end.y)
        }
        cachedPath = path
        return path
    }
    
    private func rectForCircle() -> CGRect {
        let size = CGSize(width: 2 * circleRadius, height: 2 * circleRadius)
        let origin = CGPoint(x: 0.5 * bounds.width - 0.5 * size.width,
                             y: 0.5 * bounds.height - 0.5 * size.height)
        return CGRect(origin: origin, size: size)
    }

    private func linesFor(type: JourneyStopType, circleBounds: CGRect) -> [(start: CGPoint, end: CGPoint)] {
        let x = 0.5 * bounds.width
        switch type {
        case .First: return [(CGPoint(x: x, y: circleBounds.origin.y + circleBounds.height), CGPoint(x: x, y: bounds.height))]
        case .Intermediate: return [(CGPoint(x: x, y: 0), CGPoint(x: x, y: circleBounds.origin.y)),
                                    (CGPoint(x: x, y: circleBounds.origin.y + circleBounds.height), CGPoint(x: x, y: bounds.height))]
        case .Last: return [(CGPoint(x: x, y: 0), CGPoint(x: x, y: circleBounds.origin.y))]
        }
    }
}
