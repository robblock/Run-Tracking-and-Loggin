/*

*/

import UIKit
import CoreData
import CoreLocation
import HealthKit
import MapKit
import Parse

let DetailSegueName = "RunDetails"

class NewRunViewController: UIViewController {
    var managedObjectContext: NSManagedObjectContext?
    
    var run: Run!
    var startTime = NSTimeInterval()
    
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    @IBOutlet weak var mapView: MKMapView!
    
    var seconds = 0.0
    var distance = 0.0
    
    lazy var locationManager: CLLocationManager = {
        var _locationManager = CLLocationManager()
        _locationManager.delegate = self
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest
        _locationManager.activityType = .Fitness
        
        // Movement threshold for new events
        _locationManager.distanceFilter = 10.0
        return _locationManager
        }()
    
    lazy var locations = [CLLocation]()
    lazy var timer = NSTimer()
    lazy var timerTwo = NSTimer()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        startButton.hidden = false
        promptLabel.hidden = false
        
        timeLabel.hidden = true
        distanceLabel.hidden = true
        paceLabel.hidden = true
        stopButton.hidden = true
        
        locationManager.requestAlwaysAuthorization()
        
        mapView.hidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        timer.invalidate()
    }
    
    func eachSecond(timer: NSTimer) {
        seconds++
        
//        let secondsQuantity = HKQuantity(unit: HKUnit.secondUnit(), doubleValue: seconds)
//        timeLabel.text = "Time: " + secondsQuantity.description
        
        let distanceQuantity = HKQuantity(unit: HKUnit.footUnit(), doubleValue: distance)
        distanceLabel.text = "Distance: " + distanceQuantity.description
        
        let paceUnit = HKUnit.secondUnit().unitDividedByUnit(HKUnit.footUnit())
        let paceQuantity = HKQuantity(unit: paceUnit, doubleValue: seconds / distance)
        paceLabel.text = "Pace: " + paceQuantity.description
    }
    
    func updateTime() {
        var currentTime = NSDate.timeIntervalSinceReferenceDate()
        var elapsedTime: NSTimeInterval = currentTime - startTime
        let minutes = UInt8(elapsedTime / 60.0)
        let seconds = UInt16(elapsedTime)
        
        elapsedTime -= (NSTimeInterval(minutes) * 60)
        elapsedTime -= NSTimeInterval(seconds)
        
        //let fraction = UInt8(elapsedTime * 100)

        
        let strMinutes = String(format: "%02d", minutes)
        let strSeconds = String(format: "%02d", seconds)
        
        var minutesAndSeconds = "\(strMinutes):\(strSeconds)"
        
        //let strFraction = String(format: "%02d", fraction)
        
        //concatenate minuets, seconds and milliseconds as assign it to the UILabel
        
        timeLabel.text = "Time: " + minutesAndSeconds
        
    }
    
    
    func startLocationUpdates() {
        // Here, the location manager will be lazily instantiated
        locationManager.startUpdatingLocation()
    }
    
    func saveRun() {
        // 1
        let savedRun = NSEntityDescription.insertNewObjectForEntityForName("Run",
            inManagedObjectContext: managedObjectContext!) as! Run
        savedRun.distance = distance
        savedRun.duration = seconds
        savedRun.timestamp = NSDate()
        

        // 2
        var savedLocations = [Location]()
        for location in locations {
            let savedLocation = NSEntityDescription.insertNewObjectForEntityForName("Location",
                inManagedObjectContext: managedObjectContext!) as! Location
            savedLocation.timestamp = location.timestamp
            savedLocation.latitude = location.coordinate.latitude
            savedLocation.longitude = location.coordinate.longitude
            savedLocations.append(savedLocation)
        }
        
        savedRun.locations = NSOrderedSet(array: savedLocations)
        run = savedRun
        
        // 3
        var error: NSError?
        let success = managedObjectContext!.save(&error)
        if !success {
            println("Could not save the run!")
        }
    }
    
    
    
//    func smoothStart() {
//        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), <#block: dispatch_block_t##() -> Void#>)
//    }
    
    @IBAction func startPressed(sender: AnyObject) {
        startButton.hidden = true
        promptLabel.hidden = true
        
        timeLabel.hidden = false
        distanceLabel.hidden = false
        paceLabel.hidden = false
        stopButton.hidden = false
        
        seconds = 0.0
        distance = 0.0
        locations.removeAll(keepCapacity: false)
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "eachSecond:", userInfo: nil, repeats: true)
        
        let aSelector : Selector = "updateTime"
        timerTwo = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: aSelector, userInfo: nil, repeats: true)
        
        startTime = NSDate.timeIntervalSinceReferenceDate()
        
        startLocationUpdates()
        
        mapView.hidden = false
    }
    
    //TODO: Change to alertController
    @IBAction func stopPressed(sender: AnyObject) {
        let actionSheet = UIActionSheet(title: "Run Stopped", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Save", "Discard")
        

        actionSheet.actionSheetStyle = .Default
        actionSheet.showInView(view)
        
        timer.invalidate()
        timerTwo.invalidate()
        
        locationManager.stopUpdatingLocation()
    
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let detailViewController = segue.destinationViewController as? DetailViewController {
            detailViewController.run = run
        }
    }
}

// MARK: - MKMapViewDelegate
extension NewRunViewController: MKMapViewDelegate {
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if !overlay.isKindOfClass(MKPolyline) {
            return nil
        }
        
        let polyline = overlay as! MKPolyline
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = UIColor.blueColor()
        renderer.lineWidth = 3
        return renderer
    }
}

// MARK: - CLLocationManagerDelegate
extension NewRunViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        for location in locations as! [CLLocation] {
            let howRecent = location.timestamp.timeIntervalSinceNow
            
            if abs(howRecent) < 10 && location.horizontalAccuracy < 20 {
                //update distance
                if self.locations.count > 0 {
                    distance += location.distanceFromLocation(self.locations.last)
                    
                    var coords = [CLLocationCoordinate2D]()
                    coords.append(self.locations.last!.coordinate)
                    coords.append(location.coordinate)
                    
                    let region = MKCoordinateRegionMakeWithDistance(location.coordinate, 500, 500)
                    mapView.setRegion(region, animated: true)
                    
                    mapView.addOverlay(MKPolyline(coordinates: &coords, count: coords.count))
                }
                
                //save location
                self.locations.append(location)
            }
        }
    }
}

// MARK: - UIActionSheetDelegate
extension NewRunViewController: UIActionSheetDelegate {
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        //save
        if buttonIndex == 1 {
            saveRun()
            performSegueWithIdentifier(DetailSegueName, sender: nil)
        }
            //discard
        else if buttonIndex == 2 {
            navigationController?.popToRootViewControllerAnimated(true)
        }
            //resume
        else if buttonIndex == 0 {
            timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "eachSecond:", userInfo: nil, repeats: true)
            
            let aSelector : Selector = "updateTime"
            timerTwo = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: aSelector, userInfo: nil, repeats: true)
            
            startLocationUpdates()
        }
    }
}
