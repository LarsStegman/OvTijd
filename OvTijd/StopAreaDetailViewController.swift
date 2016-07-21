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

    private struct Storyboard {
        static let cellId = "PassCell"
    }

    @IBOutlet weak var stopLocationView: MKMapView!
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        updateUI()
        tableView.delegate = self
        stopLocationView.delegate = self
    }

    var stopLocations: [TimingPoint]? {
        didSet {
            updateUI()
        }
    }

    private func updateUI() {
        
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCellWithIdentifier(Storyboard.cellId)!
    }
}
