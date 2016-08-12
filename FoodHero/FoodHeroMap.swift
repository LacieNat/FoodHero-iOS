//
//  FirstViewController.swift
//  FoodHero
//
//  Created by Lacie on 5/18/16.
//  Copyright © 2016 Lacie. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import GoogleMaps
import Alamofire
import SwiftyJSON

class FoodHeroMap: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate{
    
    
    let locationManager = CLLocationManager()
    let geoCoder = CLGeocoder()
    let coordinateOffset = 0.00005
    let dateFormatter = NSDateFormatter()
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    var mapView:GMSMapView!
    var selectedMarker:AnyObject!
    var selectedImage:UIImage!
    var iw:InfoWindow! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.delegate = self
        self.mapView.delegate = self
        
        //Check Authorization status.
        //If not authorized, request. Else, update location
        if(CLLocationManager.authorizationStatus() != CLAuthorizationStatus.AuthorizedWhenInUse) {
            self.locationManager.requestWhenInUseAuthorization()
        } else {
            updateLocation()
        }
    }
    
    //sets the mapview camera to user location
    func updateLocation() {
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        self.locationManager.distanceFilter = kCLDistanceFilterNone
        
        if #available(iOS 9.0, *) {
            self.locationManager.requestLocation()
        } else {
            self.locationManager.startUpdatingLocation()
        }
        
        self.mapView.camera = GMSCameraPosition.cameraWithTarget((self.locationManager.location?.coordinate)!, zoom: 16)
    }
    
    override func loadView() {
        super.loadView()
        
        let camera = GMSCameraPosition.cameraWithLatitude(1.285, longitude: 103.848, zoom: 16)
        self.mapView = GMSMapView.mapWithFrame(self.view.frame, camera: camera)
        
        //MAPVIEW SETTINGS
        self.mapView.settings.compassButton = true
        self.mapView.settings.myLocationButton = true
        self.mapView.myLocationEnabled = true
        self.mapView.setMinZoom(13, maxZoom: 22)
        
        //SET UI VIEW TO MAPVIEW
        self.view = self.mapView

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Location Manager Delegates
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            updateLocation()
        } else {
            self.locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //TODO
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        //TODO
    }
    
    //MARK: Map View Delegates
    func mapView(mapView: GMSMapView, idleAtCameraPosition position: GMSCameraPosition) {

        let center = getCenterCoordinate()
        let radius = getRadius()
        
        let params = ["latitude":center.latitude, "longitude": center.longitude, "radius": radius] as Dictionary<String, Double>
        let headers = ["Content-Type": "application/json", "Authorization": "Bearer " + NSUserDefaults.standardUserDefaults().stringForKey("authToken")!]
       
        Alamofire.request(.POST, appDelegate.host + "/get-events", parameters: params, encoding: .JSON , headers: headers).responseJSON { (json) in
            if let r = json.result.value{

                let arr = r["events"] as! NSArray
                //print(rows)
                //let arr = rows as! NSArray
                var markerLoc = [String:Int]()
                
                for i in 0 ..< arr.count {
                    
                    let marker = GMSMarker()
                    var latitude = arr[i]["latitude"] as! Double
                    var longitude = arr[i]["longitude"] as! Double
                    
                    if let n = markerLoc[latitude.description+","+longitude.description] {
                        if n%2 == 0 {
                            latitude = latitude + Double(n)*self.coordinateOffset
                            longitude = longitude + Double(n)*self.coordinateOffset
                            markerLoc[latitude.description+","+longitude.description] = n+1
                        } else {
                            latitude = latitude - Double(n)*self.coordinateOffset
                            longitude = longitude - Double(n)*self.coordinateOffset
                        }
                    }
                    else {
                        markerLoc[latitude.description + "," + longitude.description] = 1
                    }
                    
                    marker.position = CLLocationCoordinate2DMake(latitude, longitude)
                    //marker.title = arr[i]["roomname"] as! String
                    //marker.snippet = arr[i]["foodtype"] as! String
                    marker.userData = arr[i]
                    marker.infoWindowAnchor = CGPointMake(0.44, 0.45)
                    marker.map = self.mapView
                    
//                    let params = ["order": 0, "roomname": marker.userData!["roomname"] as! String]
//                    let headers = ["Content-Type": "application/json", "Authorization": "Bearer " + NSUserDefaults.standardUserDefaults().stringForKey("authToken")!]
//
//                    Alamofire.request(.POST, self.appDelegate.host + "/get-room-img", parameters: params as? [String : AnyObject], encoding: .JSON , headers: headers)
//                        .response{ (request, response, data, error) in
//                            if let r = data {
//                                arr[i]["image"] = data as! NSData
//                            }
//                    }
                }
                
            }
        }
        
    }
    

    
    func mapView(mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        selectedMarker = marker.userData!
        iw = NSBundle.mainBundle().loadNibNamed("InfoWindow", owner: self, options: [:])[0] as! InfoWindow
        iw.eventname.text = marker.userData!["roomname"] as? String
        iw.foodtype.text = marker.userData!["foodtype"] as? String
        print(marker.userData!["endtime"] as! String)
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let date = dateFormatter.dateFromString(marker.userData!["endtime"] as! String) {
            dateFormatter.dateFormat = "d/M HH:mm"
            iw.endtime.text = dateFormatter.stringFromDate(date)
        }
        
        let params = ["order": 0, "roomname": marker.userData!["roomname"] as! String]
        let headers = ["Content-Type": "application/json", "Authorization": "Bearer " + NSUserDefaults.standardUserDefaults().stringForKey("authToken")!]
//        iw.img.image = UIImage(named: "camera")
//        
//        Alamofire.request(.POST, appDelegate.host + "/get-room-img", parameters: params as? [String : AnyObject], encoding: .JSON , headers: headers)
//        .response{ (request, response, data, error) in
//            if let r = data {
//                self.iw.img.image = UIImage(data: r)
//            }
//        }
        
        iw.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.7)
        iw.layer.cornerRadius = 10.0
        
        return iw
    }
    
    func mapView(mapView: GMSMapView, didTapInfoWindowOfMarker marker: GMSMarker) {

        self.performSegueWithIdentifier("showFoodEventDetailSegue", sender: self)
    }

    //MARK: Map Helper Functions
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showFoodEventDetailSegue" {
            let c = segue.destinationViewController as! FoodEventDetail
            c.userData = selectedMarker
        }
        
        else if segue.identifier == "shareFoodSegue" {
            if(self.locationManager.location != nil) {
                geoCoder.reverseGeocodeLocation(self.locationManager.location!, completionHandler: { (placemarks, err) in
                    if let pm = placemarks?.last {
                        let nc = segue.destinationViewController as! UINavigationController
                        let c = nc.childViewControllers.last as! ShareFoodView
                        c.location.text = "\(pm.subThoroughfare!), \(pm.thoroughfare!), \(pm.locality!), \(pm.administrativeArea!)"
                    }
                    
                })
            }
        }
    }
    
    func getCenterCoordinate() -> CLLocationCoordinate2D {
        var centerPoint = self.mapView.center
        var centerCoordinate = self.mapView.projection.coordinateForPoint(centerPoint)
        return centerCoordinate
    }
    
    func getTopCenterCoordinate() -> CLLocationCoordinate2D {
        // to get coordinate from CGPoint of your map
        var topCenterCoor = self.mapView.convertPoint(CGPointMake(self.mapView.frame.size.width / 2.0, 0), fromView: self.mapView)
        var point = self.mapView.projection.coordinateForPoint(topCenterCoor)
        return point
    }
    
    func getRadius() -> CLLocationDistance {
        
        var centerCoordinate = getCenterCoordinate()
        // init center location from center coordinate
        var centerLocation = CLLocation(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude)
        var topCenterCoordinate = getTopCenterCoordinate()
        var topCenterLocation = CLLocation(latitude: topCenterCoordinate.latitude, longitude: topCenterCoordinate.longitude)
        
        var radius = CLLocationDistance(centerLocation.distanceFromLocation(topCenterLocation))
        
        return round(radius)
    }
    
    @IBAction func exitShareFood(segue:UIStoryboardSegue) {
    }
}


//REFERENCES


//        mapView.addObserver(self, forKeyPath: "myLocation", options: .New, context: nil)

//    override func observeValueForKeyPath(keyPath: String!, ofObject object: AnyObject!, change: [String : AnyObject]!, context: UnsafeMutablePointer<Void>) {
//        let location = change[NSKeyValueChangeNewKey] as! CLLocation
//        mapView.camera = GMSCameraPosition.cameraWithTarget(location.coordinate, zoom: 14)
//    }

//        let marker = GMSMarker()
//        marker.position = CLLocationCoordinate2DMake(-33.86, 151.20)
//        marker.title = "Sydney"
//        marker.snippet = "Australia"
//        marker.map = mapView

