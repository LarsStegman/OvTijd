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
                refreshPassData()
            }
        }
    }
    private var stops = [Stop]() {
        didSet {
            stopLocationView.removeAnnotations(stopLocationView.annotations)
            stopLocationView.addAnnotations(stops)
            stopLocationView.showAnnotations(stops, animated: true)
            updateDisplayedPasses()
            updateUI()
        }
    }
    private var selectedStop: Stop? { didSet { updateDisplayedPasses() } }

    var passes: [Pass] = [Pass]() { didSet { updateUI() } }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        stopLocationView.delegate = self
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        refreshPassData()
    }

    private func refreshPassData() {
        if let sa = stopArea {
            ovtManager.stops(sa, useIn: { [weak self] (stops) in
                dispatch_async(dispatch_get_main_queue()) {
                    self?.stops = stops
                }
            })
        }
    }

    private func updateDisplayedPasses() {
        let tempPasses: [Pass]
        if let stop = selectedStop {
            tempPasses = stop.passes
        } else {
            tempPasses = stops.flatMap({ $0.passes })
        }
        passes = tempPasses.sort({ $0.planning.expectedDeparture < $1.planning.expectedDeparture })
    }

    private func updateUI() {
        tableView.reloadData()
    }

    // - MARK: UITableViewDelegate

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return passes.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.cellId, forIndexPath: indexPath)
        guard let passCellView = cell as? PassTableViewCell else {
            return cell
        }

        passCellView.pass = passes[indexPath.row]

        return passCellView
    }

    // - MARK: MKMapViewDelegate

    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        if let annotation = view.annotation,
            let stop = annotation as? Stop {
            selectedStop = stop
            stopLocationView.showAnnotations([stop], animated: true)
        }
    }

    func mapView(mapView: MKMapView, didDeselectAnnotationView view: MKAnnotationView) {
        selectedStop = nil
    }
}

func <(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) == NSComparisonResult.OrderedAscending
}

func ==(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.isEqualToDate(rhs)
}

extension Stop: MKAnnotation {
    public var coordinate: CLLocationCoordinate2D {
        return location.coordinate
    }

    public var title: String? {
        return timingPoint.timingPointName
    }

    public var subtitle: String? {
        return "\(timingPoint.timingPointCode)"
    }
}

