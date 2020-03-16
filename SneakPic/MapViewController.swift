//
//  MapViewController.swift
//  SneakPic
//
//  Created by Michele Ruocco on 3/1/20.
//  Copyright © 2020 William. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseDatabase

class MapViewController: UIViewController {

    @IBOutlet var mapView: MKMapView!
    
    let location: NSDictionary = [
        "lat" : 40.768127,
        "long" : -73.981462
    ]
    var locationManager: CLLocationManager!
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLocationServices()
        
        ref = Database.database().reference()
        getPinData()
    }
    
    
    func createLocations() {
        ref.child("Locations").childByAutoId().setValue(location)
    }
    func setupLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.requestLocation()
            locationManager.requestWhenInUseAuthorization()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            mapView.showsUserLocation = true
            mapView.delegate = self
        }
    }
        
    
    func getPinData() {
        ref.child("Locations").observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.exists() {
                for item in snapshot.children {
                    let childSnap = item as! DataSnapshot
                    print(childSnap.value)
                    
                    let latitude = childSnap.childSnapshot(forPath: "lat").value as! CLLocationDegrees
                    let longitude = childSnap.childSnapshot(forPath: "long").value as! CLLocationDegrees
                    let loc = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    self.addPin(location: loc)
                }
            }
        })
    }
    
    func addPin(location: CLLocationCoordinate2D) {
        let pin = MKPointAnnotation()
        pin.coordinate = location
        mapView.addAnnotation(pin)
    }
    
    
    
    @IBAction func routePressed(_ sender: Any) {
//        makeRoute()
        
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


extension MapViewController: MKMapViewDelegate, CLLocationManagerDelegate {
    
//MARK: - MapView Delegates
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.blue
        
        return renderer
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }
        
        let identifier = "Annotation"
        var annotaionView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotaionView == nil {
            annotaionView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotaionView!.canShowCallout = true
        } else {
            annotaionView!.annotation = annotation
            annotaionView!.canShowCallout = true

        }
        return annotaionView
    }
    
    
    
//MARK: - Location Manager Delegates
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    }
}



//MARK: - address to coordinates
//https://stackoverflow.com/questions/42279252/convert-address-to-coordinates-swift


