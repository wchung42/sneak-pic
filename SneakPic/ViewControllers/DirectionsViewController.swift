//
//  DirectionsViewController.swift
//  SneakPic
//
//  Created by Michele Ruocco on 5/1/20.
//  Copyright © 2020 William. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class DirectionsViewController: UIViewController {

    @IBOutlet weak var directionLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    var currentCoordinate: CLLocationCoordinate2D!
    
    var post: Post?
    
    var steps = [MKRoute.Step]()
    
    var stepCounter = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        getDirections(to: destination)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let destination = MKMapItem(placemark: MKPlacemark(coordinate: post!.locationCoordinates))
        getDirections(to: destination)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.startUpdatingLocation()
        currentCoordinate = locationManager.location?.coordinate
        
        mapView.delegate = self
    }
    
    
    func getDirections(to destination: MKMapItem) {
        let sourcePlacemark = MKPlacemark(coordinate: currentCoordinate)
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        
        let directionsRequest = MKDirections.Request()
        directionsRequest.source = sourceMapItem
        directionsRequest.destination = destination
        directionsRequest.transportType = .walking
        
        let directions = MKDirections(request: directionsRequest)
        directions.calculate { (response, error) in
            if error != nil {
                print("Directions error: \(error?.localizedDescription)")
            } else {
                guard let response = response else { return }
                guard let PrimaryRoute = response.routes.first else { return }
//                print(PrimaryRoute.steps)
                
                self.mapView.addOverlay(PrimaryRoute.polyline)
                
                self.locationManager.monitoredRegions.forEach({ self.locationManager.stopMonitoring(for: $0) }) //try removing all
                
                self.steps = PrimaryRoute.steps
                //            print(self.steps)
                for i in 0 ..< PrimaryRoute.steps.count {
                    let step = PrimaryRoute.steps[i]
                    print("\(i) \(step.instructions)")
                    print("\(i) \(step.distance)")
                    let region = CLCircularRegion(center: step.polyline.coordinate, radius: 20, identifier: "\(i)")
                    self.locationManager.startMonitoring(for: region)
                    
                    //let circle = MKCircle(center: region.center, radius: region.radius)
                    //self.mapView.addOverlay(circle)
                }
                
                
                let initialMessage = "In \(self.steps[1].distance) meters, \(self.steps[1].instructions)."
                
                self.directionLabel.text = initialMessage
                self.stepCounter += 1
            }
        }
    }
    
    
    @IBAction func cancelPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
// MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is CameraViewController {
            let vc = segue.destination as? CameraViewController
            vc?.post = post
        }
    }

}

// MARK: - CLLocation Delegate
extension DirectionsViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        guard let currentLocation = locations.first else { return }
        currentCoordinate = currentLocation.coordinate
        mapView.userTrackingMode = .followWithHeading
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        stepCounter += 1
        if stepCounter < steps.count {
            let currentStep = steps[stepCounter]
            let message = "In \(currentStep.distance) meters, \(currentStep.instructions)."
            directionLabel.text = message
        } else {
            let message = "Arrived at destination"
            directionLabel.text = message
            stepCounter = 1
            locationManager.monitoredRegions.forEach({ self.locationManager.stopMonitoring(for: $0)} )
        }
    }
}

//MARK: - MapKit Delegate
extension DirectionsViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = .blue
            renderer.lineWidth = 5
            return renderer
        }
        if overlay is MKCircle {
            let renderer = MKCircleRenderer(overlay: overlay)
            renderer.strokeColor = .red
            renderer.fillColor = .red
            renderer.alpha = 0.5
            return renderer
        }
        return MKOverlayRenderer()
    }
}
