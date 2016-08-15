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
        navigationTitleView = UINavigationBarSubtitleLabel()
        navigationItem.titleView = navigationTitleView
        navigationTitleView.sizeToFit()
    }

    override var title: String? {
        didSet {
            navigationTitleView.title.text = title
        }
    }

    let manager = OVTManager.sharedInstance
    private var navigationTitleView: UINavigationBarSubtitleLabel!

    var localpassTimeCode: String? {
        didSet {
            refreshJourneyData()
        }
    }
    private var journey: Journey? {
        didSet {
            tableView.reloadData()
            if let j = journey {
                navigationTitleView?.subtitle.text = j.lineDetails.destinationName
            }
        }
    }

    @IBAction func refresh(sender: UIRefreshControl) {
        if sender.refreshing {
            refreshJourneyData()
        }
    }

    private func refreshJourneyData() {
        if let code = localpassTimeCode {
            refreshControl?.beginRefreshing()
            manager.journey([code]) { [weak self] (journeys) in
                dispatch_async(dispatch_get_main_queue()) {
                    self?.journey = journeys.first
                    self?.refreshControl?.endRefreshing()
                }
            }
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
