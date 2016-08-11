//
//  JourneyOverviewTableViewController.swift
//  OvTijd
//
//  Created by Lars Stegman on 06-08-16.
//  Copyright © 2016 Stegman. All rights reserved.
//

import UIKit

import OvTijdCore

class JourneyOverviewTableViewController: UITableViewController {

    private struct Constants {
        static let CellId = "JourneyPassCell"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.titleView = UINavigationBarSubtitleLabel()
    }

    let manager = OVTManager.sharedInstance

    var localpassTimeCode: String? {
        didSet {
            refreshJourneyData()
        }
    }
    private var journey: Journey? {
        didSet {
            tableView.reloadData()
        }
    }

    private func refreshJourneyData() {
        if let code = localpassTimeCode {
            manager.journey([code]) { [weak self] (journeys) in
                dispatch_async(dispatch_get_main_queue()) {
                    self?.journey = journeys.first
                }
            }
        }
    }
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return journey?.passes.count ?? 0
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.CellId, forIndexPath: indexPath)
        guard let jPCell = cell as? JourneyPassCellTableViewCell else {
            return cell
        }

        jPCell.pass = journey?.passes[indexPath.row]

        return jPCell
    }
}
