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

class FeedViewController: UIViewController {

    @IBOutlet weak var feedTableView: UITableView!
    
    @IBOutlet weak var mapView: MKMapView!
    
    var refreshController: UIRefreshControl!
    var posts = [Post]()
    var visiblePosts: [Post] = []
    
    let nyc = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        refreshController = UIRefreshControl()
        feedTableView.addSubview(refreshController)
        refreshController.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshController.addTarget(self, action: #selector(getPosts), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setMapInitCoordinates()
        configureTableView()
        
        getPosts()
    }
    
    @objc func getPosts() {
        UserService.posts(for: Auth.auth().currentUser!) { (posts) in
            self.posts = posts
            self.feedTableView.reloadData()
            self.showPointsOnMap()
        }
        refreshController.endRefreshing()

    }
    
    func configureTableView() {
        feedTableView.tableFooterView = UIView()
        feedTableView.separatorStyle = .singleLine
    }
    
    func showPointsOnMap() {
        mapView.removeAnnotations(mapView.annotations)
        
        for post in posts {
            let pin = MapPin(point: post)
            mapView.addAnnotation(pin)
        }
    }
    
    func setMapInitCoordinates() {
        mapView.setCenter(nyc, animated: true)
        let visibleRegion = MKCoordinateRegion(center: nyc, latitudinalMeters: 100000, longitudinalMeters: 100000)
        self.mapView.setRegion(self.mapView.regionThatFits(visibleRegion), animated: true)
    }
    
    func filterVisiblePost() {
        let visibleAnnotations = self.mapView.annotations(in: self.mapView.visibleMapRect)
        var annotations = [MapPin]()
        for visibleAnnotation in visibleAnnotations {
            if let annotation = visibleAnnotation as? MapPin {
                annotations.append(annotation)
            }
        }
        self.visiblePosts = annotations.map({$0.post})
        self.feedTableView.reloadSections(IndexSet(integer: 0), with: .automatic)
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

// MARK: - UITableViewDataSource

extension FeedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostImageCell", for: indexPath) as! PostImageCell
        
        let imageURL = URL(string: post.imageURL)
        cell.postImageView.kf.setImage(with: imageURL)
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension FeedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let post = posts[indexPath.row]
        
        return post.imageHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let point = posts[indexPath.row]
        if let annotation = (mapView.annotations as? [MapPin])?.filter({ $0.post == point}).first {
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
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        filterVisiblePost()
    }
}
