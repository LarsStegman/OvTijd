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

    var lineId: String? {
        didSet {
            updateIcon()
        }
    }
    var transportType: Transport? {
        didSet {
            updateIcon()
        }
    }

    let dateFormatter: NSDateFormatter = {
        let df = NSDateFormatter()
        df.dateStyle = .NoStyle
        df.timeStyle = .ShortStyle
        return df
    }()

    var passTime = NSDate() {
        didSet {
            passingTime.text = dateFormatter.stringFromDate(passTime)
        }
    }

    func updateIcon() {
        if let id = lineId,
            let transport = transportType {
            lineImage.image = generateIcon(line: id, transport: transport)
        }
    }

    private func generateIcon(line line: String, transport: Transport) -> UIImage {
        let image = UIImage()

        return image
    }
}
