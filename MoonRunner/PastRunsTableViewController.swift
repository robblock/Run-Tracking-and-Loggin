//
//  PastRunsTableViewController.swift
//  MoonRunner
//
//  Created by Rob Block on 8/28/15.
//  Copyright (c) 2015 Zedenem. All rights reserved.
//

import UIKit
import MapKit
import HealthKit


class PastRunsTableViewController: UITableViewController {
    
    //MARK: - Variables
    //Setting up Variables to recieve data from DetailViewController
    var run: Run!
    var runPasado: PastRun!
    
    var mapRegion: MKCoordinateRegion!
    var colorSegments: [MulticolorPolylineSegment]!
    var locations: NSOrderedSet!
    var distanceQuantity: HKQuantity!
    var secondsQuantity: HKQuantity!
    var paceUnit: HKUnit!
    var paceQuantity: HKQuantity!
    var dateOfRun: NSDate!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return 4
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! PastRunTableViewCell
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        

        //If save is clicked on detailController, then populate a new cell with data.
        cell.mapView.region = mapRegion
        cell.distanceLabel.text = "Distance: " + distanceQuantity.description
        cell.timeLabel.text = "Time: " + secondsQuantity.description
        cell.paceLabel.text = "Pace: " + paceQuantity.description
        cell.testLabel.text = "Test"
        cell.dateLabel.text = dateFormatter.stringFromDate(dateOfRun)
        
        
        //Adding overlay
        cell.mapView.addOverlays(colorSegments)

        return cell
    }
    

    //MARK: - Actions & Outlets

  }


