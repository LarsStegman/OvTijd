//
//  StopsOverviewTableViewController.swift
//  OvTijd
//
//  Created by Lars Stegman on 08-07-16.
//  Copyright © 2016 Stegman. All rights reserved.
//

import UIKit
import OvTijdCore
import CoreLocation

class StopsOverviewTableViewController: UITableViewController, OVTLocationManagerDelegate {

    private struct Constants {
        static let Nearby = "Nearby"
        static let StopAreaCellId = "StopAreaCell"
        static let SectionTitles = [Constants.Nearby]
        static let distanceFilter = 100.0
    }

    let manager: OVTManager = OVTManager.sharedInstance
    let locationManager = OVTLocationManager.sharedInstance

    // MARK: - Data management

    @IBAction func refresh(sender: UIRefreshControl) {
        if sender.refreshing {
            refreshStopAreas()
        }
    }

    private func refreshStopAreas() {
        if let newLocation = location {
            if let refresh = refreshControl {
                tableView.setContentOffset(CGPoint(x: 0, y: tableView.contentOffset.y - refresh.frame.size.height), animated: true)
                refresh.beginRefreshing()
            }

            manager.stopAreas(newLocation) {
                [weak self] (stopAreas: [StopArea]) in
                if newLocation == self?.location { // Location might have changed already
                    dispatch_async(dispatch_get_main_queue()) {
                        self?.stopAreas[Constants.Nearby] = stopAreas
                        self?.refreshControl?.endRefreshing()
                    }
                }
            }
        }
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        automaticallyAdjustsScrollViewInsets = true
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        locationManager.startUpdatingLocations(forDelegate: self)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.stopUpdateLocations(forDelegate: self)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let stopAreaDetailVC = segue.destinationViewController as? StopAreaDetailViewController,
            let selectedCellIndex = tableView.indexPathForSelectedRow
        {
            let stopArea = dataFor(selectedCellIndex)
            stopAreaDetailVC.title = stopArea.name
            stopAreaDetailVC.stopArea = stopArea
        }
    }

    // MARK: - Location Managing

    var location: CLLocation? {
        didSet {
            refreshStopAreas()
        }
    }

    func update(location: CLLocation) {
        self.location = location
    }

    func fail(with: OVTError) {
        // Nothing yet
    }

    // MARK: - Table view data source

	/**
		The stop areas that will appear in the table view. Each entry's key is the title for the section.
	*/
    var stopAreas = [String: [StopArea]]() {
		didSet {
			tableView.reloadData()
		}
	}

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return Constants.SectionTitles.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stopAreas[Constants.SectionTitles[section]]?.count ?? 0
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Constants.SectionTitles[section]
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.StopAreaCellId, forIndexPath: indexPath)
        guard let stopAreaCell = cell as? StopAreaTableViewCell else {
            return cell
        }

        let stopArea = dataFor(indexPath)
        stopAreaCell.stopAreaName.text = stopArea.name
        stopAreaCell.stopAreaTown.text = stopArea.town
        stopAreaCell.distance = self.location?.distanceFromLocation(stopArea.location)

        return stopAreaCell
    }

    private func dataFor(index: NSIndexPath) -> StopArea {
        let sectionName = Constants.SectionTitles[index.section]
        let stopAreasInSection = stopAreas[sectionName]!
        return stopAreasInSection[index.row]
    }
}

