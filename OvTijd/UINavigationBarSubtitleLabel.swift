//
//  UINavigationBarSubtitleLabel.swift
//  OvTijd
//
//  Created by Lars Stegman on 06-08-16.
//  Copyright © 2016 Stegman. All rights reserved.
//

import UIKit

@IBDesignable
class UINavigationBarSubtitleLabel: UIView {

    let title = UILabel()
    let subtitle = UILabel()

    var titleText: String? {
        didSet {
            title.text = titleText ?? " "
        }
    }

    var subtitleText: String? {
        didSet {
            subtitle.text = subtitleText ?? " "
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    private func setup() {
        addSubview(title)
        addSubview(subtitle)
        autoresizingMask = .FlexibleTopMargin

        title.translatesAutoresizingMaskIntoConstraints = false
        subtitle.translatesAutoresizingMaskIntoConstraints = false

        subtitle.allowsDefaultTighteningForTruncation = true
        subtitle.minimumScaleFactor = 0.5

        title.text = " "
        subtitle.text = " "
        subtitle.font = subtitle.font.fontWithSize(UIFont.smallSystemFontSize())
        opaque = false

        var constraints = [NSLayoutConstraint]()
        constraints.append(NSLayoutConstraint(item: title, attribute: .Top, relatedBy: .Equal,
            toItem: self, attribute: .Top, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: title, attribute: .CenterX, relatedBy: .Equal,
            toItem: self, attribute: .CenterX, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: subtitle, attribute: .CenterX, relatedBy: .Equal,
            toItem: self, attribute: .CenterX, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: subtitle, attribute: .Top, relatedBy: .Equal,
            toItem: title, attribute: .Bottom, multiplier: 1, constant: 2))


        NSLayoutConstraint.activateConstraints(constraints)
        invalidateIntrinsicContentSize()
    }

    override func sizeThatFits(size: CGSize) -> CGSize {
        let titleSize = title.sizeThatFits(CGSize(width: size.width, height: (size.height - 2) / 2))
        let subtitleSize = subtitle.sizeThatFits(CGSize(width: size.width, height: (size.height - 2) / 2))

        let newSize = CGSize(width: max(titleSize.width, subtitleSize.width),
                             height: titleSize.height + subtitleSize.height + 2)

        return newSize
    }
}