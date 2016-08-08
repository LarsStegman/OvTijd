//
//  UINavigationBarSubtitleLabel.swift
//  OvTijd
//
//  Created by Lars Stegman on 06-08-16.
//  Copyright © 2016 Stegman. All rights reserved.
//

import UIKit

class UINavigationBarSubtitleLabel: UIView {

    let title = UILabel()
    let subtitle = UILabel()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    private func setup() {
        var constraints = [NSLayoutConstraint]()
        constraints.append(NSLayoutConstraint(item: title, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: title, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: subtitle, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: subtitle, attribute: .Top, relatedBy: .Equal, toItem: title, attribute: .Bottom, multiplier: 1, constant: 8))

        title.text = "Title"
        subtitle.text = "Subtitle"
    }

}
