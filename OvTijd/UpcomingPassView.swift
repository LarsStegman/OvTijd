//
//  UpcomingPassView.swift
//  OvTijd
//
//  Created by Lars Stegman on 19-07-16.
//  Copyright © 2016 Stegman. All rights reserved.
//

import UIKit
import OvTijdCore

@IBDesignable
class UpcomingPassView: UIView {

    @IBOutlet weak var lineImage: UIImageView!
    @IBOutlet weak var passingTime: UILabel!

    var lineId: String? = "Bus!"
    var type: Transport = .Bus

    let df = NSDateFormatter()

    var passTime = NSDate()
}
