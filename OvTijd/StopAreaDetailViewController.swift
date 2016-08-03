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
            stopLocationView.showAnnotations(stops, animated: false)
            passes = stops.flatMap({ $0.passes }).sort({ $0.planning.expectedDeparture < $1.planning.expectedDeparture })
            updateUI()
        }
    }
    private var selectedStop: Stop? {
        didSet {
            if selectedStop != nil {
                stopLocationView.showAnnotations([selectedStop!], animated: true)
            } else {
                stopLocationView.showAnnotations(stops, animated: true)
            }
            updateVisiblePasses()
        }
    }

    var passes = [Pass]() { didSet { tableView.reloadData() } }
    var hiddenPassIndeces = [Int]() { didSet { updateUI() } }

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
        } else {
            passes = [Pass]()
        }
    }

    private func updateVisiblePasses() {
        if let stop = selectedStop {
            var elemIndeces = [Int]()
            for (index, pass) in passes.enumerate() where pass.timingPoint.timingPointCode != stop.timingPoint.timingPointCode {
                elemIndeces.append(index)
            }
            hiddenPassIndeces = elemIndeces
        } else {
            hiddenPassIndeces = [Int]()
        }
    }

    private func updateUI() {
        tableView.beginUpdates()
        tableView.endUpdates()
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

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return shouldHideRow(at: indexPath) ? 0.0 : tableView.rowHeight
    }

    private func shouldHideRow(at indexPath: NSIndexPath) -> Bool {
        return hiddenPassIndeces.contains(indexPath.row)
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let pass = passes[indexPath.row]
        if let stop = pass.stop {
            stopLocationView.selectAnnotation(stop, animated: true)
        }
    }

    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let pass = passes[indexPath.row]
        if let stop = pass.stop {
            stopLocationView.deselectAnnotation(stop, animated: true)
        }
    }

    // - MARK: MKMapViewDelegate

    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        if let annotation = view.annotation,
            let stop = annotation as? Stop {
            selectedStop = stop
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

