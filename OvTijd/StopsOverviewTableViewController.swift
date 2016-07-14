//
//  StopsOverviewTableViewController.swift
//  OvTijd
//
//  Created by Lars Stegman on 08-07-16.
//  Copyright © 2016 Stegman. All rights reserved.
//

import UIKit
import OvTijdCore

class StopsOverviewTableViewController: UITableViewController {

    private struct Constants {
        static let Nearby = "Nearby"
        static let StopAreaCellId = "StopAreaCell"
        static let SectionTitles = [Constants.Nearby]
    }

    let manager = OvTijdManager()

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print("View will appear")
        manager.nearbyStopAreas { [weak self] stopAreas in
            dispatch_async(dispatch_get_main_queue()) {
                self?.stopAreas[Constants.Nearby] = stopAreas
            }
        }
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
        let sectionName = Constants.SectionTitles[indexPath.section]
        let stopAreasInSection = stopAreas[sectionName]!

        let stopArea = stopAreasInSection[indexPath.row]
        stopAreaCell.stopAreaName.text = stopArea.name
        // Configure the cell...

        return stopAreaCell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
