//
//  StopAreaDetailViewController.swift
//  OvTijd
//
//  Created by Lars Stegman on 21-07-16.
//  Copyright © 2016 Stegman. All rights reserved.
//

import UIKit
import OvTijdCore
import CoreLocation
import MapKit

class StopAreaDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate {

    let ovtManager = OVTManager.sharedInstance
    private struct Storyboard {
        static let cellId = "PassCell"
    }

    @IBOutlet weak var stopLocationView: MKMapView!
    @IBOutlet weak var tableView: UITableView!

    var stopArea: StopArea? {
        didSet {
            if stopArea != oldValue {
                updateData()
            }
        }
    }
    private var stops = [Stop]() { didSet { updateUI() } }
    var passes: [Pass] {
        get { // This should probably be changed to a stored property; it's quite an expensive operation
            return stops.flatMap({ $0.passes }).sort({ $0.planning.expectedDeparture < $1.planning.expectedDeparture })
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        stopLocationView.delegate = self
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateData()
    }

    private func updateData() {
        if let sa = stopArea {
            ovtManager.stops(sa, useIn: { [weak self] (stops) in
                dispatch_async(dispatch_get_main_queue()) {
                    self?.stops = stops
                }
            })
        }
    }

    private func updateUI() {
        tableView.reloadData()
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return passes.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.cellId, forIndexPath: indexPath)
        guard let passCellView = cell as? PassTableViewCell else {
            return cell
        }
        let pass = passes[indexPath.row]
        passCellView.direction = pass.lineDetails.destinationName
        passCellView.currentPassTime = pass.planning.expectedDeparture
        passCellView.type = pass.transportType
        passCellView.lineId = pass.lineDetails.publicNumber

        return passCellView
    }
}

func <(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) == NSComparisonResult.OrderedAscending
}

func ==(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.isEqualToDate(rhs)
}

