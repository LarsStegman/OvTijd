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

class StopAreaDetailViewController: UIViewController,
                                    UITableViewDelegate,
                                    UITableViewDataSource,
                                    MKMapViewDelegate {

    let ovtManager = OVTManager.sharedInstance
    private struct Storyboard {
        static let cellId = "PassCell"
    }

    @IBOutlet weak var stopLocationView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messagesView: ScrollingMessages!
    @IBOutlet weak var messagesViewContainer: UIView!

    var refreshControl = UIRefreshControl()
    private var refreshTimer: NSTimer?

    var stopArea: StopArea?
    private var stops = [Stop]() {
        didSet {
            let oldAnnotations = stopLocationView.annotations
            stopLocationView.addAnnotations(stops)
            stopLocationView.showAnnotations(stops, animated: true)
            stopLocationView.removeAnnotations(oldAnnotations)
            passes = stops.flatMap({ $0.passes })
            messages = stops.flatMap({ $0.messages }).filter({ $0.shouldBeDisplayed })
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

    /**
     An array of passes sorted ascending on departure time.
     */
    private var storedPasses = [Pass]()

    /**

     */
    var passes: [Pass] {
        set {
            storedPasses = newValue.sort({ $0.planning.expectedDepartureTime < $1.planning.expectedDepartureTime })
            updateUI()
        }
        get {
            return storedPasses
        }
    }
    private var storedMessages = [Message]()
    var messages: [Message] {
        set {
            if newValue != storedMessages {
                messagesViewContainer?.hidden = !(newValue.count > 0)
                let uniqueMessages = Array(Set<String>(newValue.map({ $0.content })))
                messagesView.messages = uniqueMessages
                storedMessages = newValue
            }
        }
        get {
            return storedMessages
        }
    }

    var hiddenPassIndeces = [Int]() { didSet { updateUI() } }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        stopLocationView.delegate = self
        refreshControl.addTarget(self, action: #selector(StopAreaDetailViewController.refresh(_:)),
                                 forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
        tableView.tableFooterView = UIView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let line = CALayer()
        line.frame = CGRect(x: stopLocationView.bounds.origin.x,
                            y: stopLocationView.bounds.height - 1,
                            width: stopLocationView.bounds.width, height: 1)
        line.backgroundColor = UIColor.lightGrayColor().CGColor
        stopLocationView.layer.addSublayer(line)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        validateTimer()
        refreshTimer?.fire()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        messagesView.startAnimating()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        refreshTimer?.invalidate()
        refreshTimer = nil
        messagesView.stopAnimating()
    }

    func refresh(sender: UIRefreshControl) {
        refreshTimer?.fire()
    }

    func refreshPassData() {
        if let sa = stopArea {
            refreshControl.beginRefreshing()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            ovtManager.stops(sa, useIn: { [weak self] (stops) in
                dispatch_async(dispatch_get_main_queue()) {
                    self?.stops = stops
                    self?.refreshControl.endRefreshing()
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                }
            })
        } else {
            self.stops = [Stop]()
        }
    }

    private func validateTimer() {
        refreshTimer = NSTimer.scheduledTimerWithTimeInterval(30, target: self,
                                                              selector: #selector(StopAreaDetailViewController.refreshPassData),
                                                              userInfo: nil, repeats: true)
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

    private var earliestNextPassIndexPath: NSIndexPath {
        for i in 0..<passes.count {
            if passes[i].status != .Passed {
                return NSIndexPath(forRow: i, inSection: 0)
            }
        }

        return NSIndexPath(forRow: 0, inSection: 0)
    }

    private lazy var noDeparturesMessage: ScreenFillingMessage = {
        let view = NSBundle.mainBundle().loadNibNamed("ScreenFillingMessage", owner: self, options: nil).first! as! ScreenFillingMessage
        view.messageLabel.text = "Op dit moment vertrekken er geen ritten vanaf deze locatie"
        return view
    }()

    private func updateUI() {
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView.reloadData()
            if self.passes.count > 0 {
                self.noDeparturesMessage.removeFromSuperview()
                self.tableView.scrollEnabled = true
                self.tableView.scrollToRowAtIndexPath(self.earliestNextPassIndexPath, atScrollPosition: .Top,
                                                      animated: true)
            } else {
                self.tableView.backgroundView = self.noDeparturesMessage
                self.tableView.scrollEnabled = false
            }
        }
    }

    // - MARK: UIView

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if  let destinationVC = segue.destinationViewController as? JourneyOverviewTableViewController,
            let selectedCellIndex = tableView.indexPathForSelectedRow {
            let pass = passes[selectedCellIndex.row]
            destinationVC.localpassTimeCode = pass.code
            destinationVC.title = "\(pass.lineDetails.transportType) \(pass.lineDetails.publicNumber)"
        }
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

