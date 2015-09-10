//
//  PastRunTableViewCell.swift
//  MoonRunner
//
//  Created by Rob Block on 8/28/15.
//  Copyright (c) 2015 Zedenem. All rights reserved.
//

import UIKit
import MapKit

class PastRunTableViewCell: UITableViewCell {
    
    //MARK: - Actions & Outlets
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var testLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
}
