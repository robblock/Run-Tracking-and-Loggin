/*

*/

import UIKit
import MapKit
import HealthKit
import CoreData
import Parse

class DetailViewController: UIViewController {

    var run: Run!

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    @IBOutlet weak var saveRun: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        

    }
    
   func configureView() {
        let distanceQuantity = HKQuantity(unit: HKUnit.footUnit(), doubleValue: run.distance.doubleValue)
        distanceLabel.text = "Distance: " + distanceQuantity.description
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        dateLabel.text = dateFormatter.stringFromDate(run.timestamp)
        
        let secondsQuantity = HKQuantity(unit: HKUnit.secondUnit(), doubleValue: run.duration.doubleValue)
        timeLabel.text = "Time: " + secondsQuantity.description
        
        let paceUnit = HKUnit.secondUnit().unitDividedByUnit(HKUnit.meterUnit())
        let paceQuantity = HKQuantity(unit: paceUnit, doubleValue: run.duration.doubleValue / run.distance.doubleValue)
        paceLabel.text = "Pace: " + paceQuantity.description
        
        loadMap()
    }
    
    
    func mapRegion() -> MKCoordinateRegion {
        
        
        let initialLoc = run.locations.firstObject as! Location
        
        var minLat = initialLoc.latitude.doubleValue
        var minLng = initialLoc.longitude.doubleValue
        var maxLat = minLat
        var maxLng = minLng
        
        let locations = run.locations.array as! [Location]
        
        for location in locations {
            minLat = min(minLat, location.latitude.doubleValue)
            minLng = min(minLng, location.longitude.doubleValue)
            maxLat = max(maxLat, location.latitude.doubleValue)
            maxLng = max(maxLng, location.longitude.doubleValue)
        }
        
        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: (minLat + maxLat)/2,
                longitude: (minLng + maxLng)/2),
            span: MKCoordinateSpan(latitudeDelta: (maxLat - minLat)*1.1,
                longitudeDelta: (maxLng - minLng)*1.1))
    }
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if !overlay.isKindOfClass(MulticolorPolylineSegment) {
            return nil
        }
        
        let polyline = overlay as! MulticolorPolylineSegment
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = polyline.color
        renderer.lineWidth = 3
        return renderer
    }
    
    func polyline() -> MKPolyline {
        var coords = [CLLocationCoordinate2D]()
        
        let locations = run.locations.array as! [Location]
        for location in locations {
            coords.append(CLLocationCoordinate2D(latitude: location.latitude.doubleValue,
                longitude: location.longitude.doubleValue))
        }
        
        return MKPolyline(coordinates: &coords, count: run.locations.count)
    }
    
    func loadMap() {
        if run.locations.count > 0 {
            mapView.hidden = false
            
            // Set the map bounds
            mapView.region = mapRegion()
            
            // Make the line(s!) on the map
            let colorSegments = MulticolorPolylineSegment.colorSegments(forLocations: run.locations.array as! [Location])
            mapView.addOverlays(colorSegments)
        } else {
            // No locations were found!
            mapView.hidden = true
            
            UIAlertView(title: "Error",
                message: "Sorry, this run has no locations saved",
                delegate:nil,
                cancelButtonTitle: "OK").show()
        }
    }
    
    //TODO: Add MKPolyline Overlay
    func mapSnapshot()  {
        var snapShotterOptions = MKMapSnapshotOptions()
        snapShotterOptions.region = mapView.region
        snapShotterOptions.scale = UIScreen.mainScreen().scale
        snapShotterOptions.size = mapView.frame.size
        
        var finalImage = UIImage()
        var snapShotter = MKMapSnapshotter(options: snapShotterOptions)
        
        snapShotter.startWithCompletionHandler { (snapshot:MKMapSnapshot!, error:NSError!) -> Void in
            if(error != nil) {
                println("error: " + error.localizedDescription);
                return
            }
            
            var image:UIImage = snapshot.image
            var data:NSData = UIImagePNGRepresentation(image)
            
            //1
            let file = PFFile(name: "CompletedRun", data: data)
            file.saveInBackgroundWithBlock({ (succeeded, error) -> Void in
                if succeeded {
                    //2
                    self.saveToParse(file)
                } else if let error = error {
                    //3
                    self.showErrorView(error)
                }
                }, progressBlock: { percent in
                    //4
                    println("Uploaded: \(percent)%")
            })
        }
    }

    //TODO: Make catagory and value seperate labels
    func saveToParse(file: PFFile) {
        let user = PFUser()
        
        let pastRun = PastRun(image: file, pace: self.paceLabel.text!, timeStamp: self.timeLabel.text!, date: self.dateLabel.text!, distance: self.distanceLabel.text!)
        
        pastRun.saveInBackgroundWithBlock { succeeded, error in
            if succeeded {
                println("Saved!")
            } else {
                if let errorMessage = error?.userInfo?["error"] as? String {
                    self.showErrorView(error!)
                }
            }
        }
    }
    
    
    //Passing variables to PastRuns Controller
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SaveRunToTableView" {
            
            mapSnapshot()
            
            let paceUnit = HKUnit.secondUnit().unitDividedByUnit(HKUnit.meterUnit())
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = .MediumStyle
            let colorSegments = MulticolorPolylineSegment.colorSegments(forLocations: run.locations.array as! [Location])

            //Get the destination controller
            let controller = segue.destinationViewController as! PastRunsTableViewController
            
            //Sending data to PastRunsTableViewController
            controller.mapRegion = mapRegion()
            controller.colorSegments = colorSegments
            controller.distanceQuantity = HKQuantity(unit: HKUnit.meterUnit(), doubleValue: run.distance.doubleValue)
            controller.secondsQuantity = HKQuantity(unit: HKUnit.secondUnit(), doubleValue: run.duration.doubleValue)
            controller.paceUnit = HKUnit.secondUnit().unitDividedByUnit(HKUnit.meterUnit())
            controller.paceQuantity = HKQuantity(unit: paceUnit, doubleValue: run.duration.doubleValue / run.distance.doubleValue)
            controller.dateOfRun = run.timestamp
            
            
            
        }
    }
    
}

//MARK: - DecimalFormatter
extension Double {
    func format(f: String) -> String {
        return String(format: "%/(f)f", self)
    }
}
// MARK: - MKMapViewDelegate
extension DetailViewController: MKMapViewDelegate {
}
    
extension UIViewController {
        func showErrorView(error: NSError) {
            if let errorMessage = error.userInfo?["error"] as? String {
                let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                presentViewController(alert, animated: true, completion: nil)
            }
        }
}