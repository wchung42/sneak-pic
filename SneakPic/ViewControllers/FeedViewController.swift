//
//  FeedViewController.swift
//  SneakPic
//
//  Created by Michele Ruocco on 3/21/20.
//  Copyright © 2020 William. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher
import MapKit
import CoreLocation

class FeedViewController: UIViewController {

    @IBOutlet weak var feedTableView: UITableView!
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    let locationManager = CLLocationManager()
    
    var posts = [Post]()
    var selectedPostWithLocID: [Post] = []
    var selectedPost: Post?
    
    var locationPosts = [[Post]]()
    var postLocations = [Post]()
    let nyc = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
    
    var annotationIsSelected = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        setupLocationServices()
        
        setMapInitCoordinates()
        configureTableView()
        mapView.delegate = self
//        mapView.showsUserLocation = true
        getPosts()
        getPostByLocation()
//        print(locationPosts)
//        for i in locationPosts {
//            print(i)
//        }
    }
    
    func setupLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
//            locationManager.delegate = self
//            locationManager.startUpdatingLocation()
        }
    }
    
//    @objc func getPosts() {
//        UserService.posts(for: Auth.auth().currentUser!) { (posts) in
//            self.posts = posts
//            self.feedTableView.reloadData()
//            self.showPointsOnMap()
//            print(posts)
//        }
//        refreshController.endRefreshing()
//
//    }
    
    func getPosts() {
        let ref = Database.database().reference().child("photos")
        ref.observe(.value) { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else {
                print("no posts...")
                return
            }
//            print(snapshot)
            self.posts = snapshot.reversed().compactMap(Post.init)
            self.feedTableView.reloadData()
            self.selectedPostWithLocID = self.posts
//            self.showPointsOnMap()
//            print(self.posts)
        }
    }
    
    
    func getPostByLocation() {
        let ref = Database.database().reference()
        ref.child("Locations").observe(.value) { (locSnapshot) in
            guard let locSnap = locSnapshot.children.allObjects as? [DataSnapshot] else {
                print("no locations")
                return
            }
            for locKey in locSnap {
                ref.child("photos").queryOrdered(byChild: "locationID").queryEqual(toValue: locKey.key).observeSingleEvent(of: .value) { (snapshot) in
                    guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else {
                        print("some error")
                        return
                    }
//                     print(snapshot)
                    let arrayOfPosts = snapshot.reversed().compactMap(Post.init)
                    self.locationPosts.append(arrayOfPosts)
                    
//                    print(arrayOfPosts[0])
                    self.postLocations.append(arrayOfPosts[0])
//                    print(self.postLocations)
                    self.showPointsOnMap()

                }
            }
//            print(self.postLocations)
        }
        

    }
    
    func configureTableView() {
        feedTableView.tableFooterView = UIView()
        feedTableView.separatorStyle = .singleLine
    }
    
    func showPointsOnMap() {
        mapView.removeAnnotations(mapView.annotations)
        
        for post in postLocations {
            let pin = MapPin(point: post)
            mapView.addAnnotation(pin)
        }
    }
    
    func setMapInitCoordinates() {
        mapView.setCenter(nyc, animated: true)
        let visibleRegion = MKCoordinateRegion(center: nyc, latitudinalMeters: 100000, longitudinalMeters: 100000)
        self.mapView.setRegion(self.mapView.regionThatFits(visibleRegion), animated: true)
    }
    
//    func filterVisiblePost() {
//        let visibleAnnotations = self.mapView.annotations(in: self.mapView.visibleMapRect)
//        var annotations = [MapPin]()
//        for visibleAnnotation in visibleAnnotations {
//            if let annotation = visibleAnnotation as? MapPin {
//                annotations.append(annotation)
//            }
//        }
//        self.visiblePosts = annotations.map({$0.post})
//        self.feedTableView.reloadSections(IndexSet(integer: 0), with: .automatic)
//    }

    
    
// MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is DirectionsViewController {
            let vc = segue.destination as? DirectionsViewController
            vc?.post = selectedPost!
        }
    }
    
    @IBAction func unwinde(_ seg: UIStoryboardSegue) {
        
    }

}

// MARK: - UITableViewDataSource

extension FeedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch annotationIsSelected {
        case true:
            return selectedPostWithLocID.count
        default:
            return posts.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var post: Post
        
        switch annotationIsSelected {
        case true:
            print(indexPath.row)
            post = selectedPostWithLocID[indexPath.row]
        default:
            post = posts[indexPath.row]
        }
        
//        let post = posts[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostImageCell", for: indexPath) as! PostImageCell
        
        let imageURL = URL(string: post.imageURL)
        cell.postImageView.kf.setImage(with: imageURL)
        cell.post = post
        cell.delegate = self
        
        return cell
    }
}

extension FeedViewController: PostImageCellDelegate {
    func getDirections(_ postImageCell: PostImageCell, directionButtonTappedFor post: Post) {
       selectedPost = post
        print("get directions")
    }
}

// MARK: - UITableViewDelegate

extension FeedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        let post = posts[indexPath.row]
        
        return 550
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let point = posts[indexPath.row]
        if let annotation = (mapView.annotations as? [MapPin])?.filter({ $0.post.LocationID == point.LocationID}).first {
            selectPinPointOnMap(annotation: annotation)
        }
    }
    
    
    func selectPinPointOnMap(annotation: MapPin) {
        mapView.selectAnnotation(annotation, animated: true)
        if CLLocationCoordinate2DIsValid(annotation.coordinate) {
            self.mapView.setCenter(annotation.coordinate, animated: true)
        }
    }
}

// MARK: - MapView Delegates
extension FeedViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }
        
        let identifier = "Annotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView!.canShowCallout = true
        } else {
            annotationView!.annotation = annotation
            annotationView!.canShowCallout = true
        }
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("annotation selected")
        if let annotation = view.annotation as? MapPin {
            annotationIsSelected = true
            selectedPostWithLocID = posts.filter { $0.LocationID == annotation.post.LocationID}
            DispatchQueue.main.async { self.feedTableView.reloadData() }
//            print("annotation selected \(annotation.post.LocationID)")
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        print("annotation deselected")
            annotationIsSelected = false
            DispatchQueue.main.async { self.feedTableView.reloadData() }
    }

}


extension FeedViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}
