//
//  Post.swift
//  SneakPic
//
//  Created by Michele Ruocco on 3/19/20.
//  Copyright © 2020 William. All rights reserved.
//

import UIKit
import FirebaseDatabase
import CoreLocation

class Post {
    var key: String?
    let imageURL: String
    let imageHeight: CGFloat
    let creationDate: Date
    let locationCoordinates: CLLocationCoordinate2D
    let altitude: CLLocationDistance
    init(imageURL: String, imageHeight: CGFloat, location: CLLocation) {
        self.imageURL = imageURL
        self.imageHeight = imageHeight
        self.creationDate = Date()
        self.locationCoordinates = location.coordinate
        self.altitude = location.altitude
        
    }
    
    var dictValue: [String : Any] {
        let createdAgo = creationDate.timeIntervalSince1970
        
        return ["image_url" : imageURL,
                "image_height" : imageHeight,
                "created_at" : createdAgo,
                "latitude" : locationCoordinates.latitude,
                "longitude" : locationCoordinates.longitude,
                "altitude" : altitude]
    }
    
    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String : Any],
            let imageURL = dict["image_url"] as? String,
            let imageHeight = dict["image_height"] as? CGFloat,
            let createdAgo = dict["created_at"] as? TimeInterval,
            let lat = dict["latitude"] as? CLLocationDegrees,
            let long = dict["longitude"] as? CLLocationDegrees,
            let altitude = dict["altitude"] as? CLLocationDistance
        else { return nil }
        
        self.key = snapshot.key
        self.imageURL = imageURL
        self.imageHeight = imageHeight
        self.creationDate = Date(timeIntervalSince1970: createdAgo)
        self.locationCoordinates = CLLocationCoordinate2D(latitude: lat, longitude: long)
        self.altitude = altitude
    }
    
    static func ==(lhs: Post, rhs: Post) -> Bool {
        return lhs.key == rhs.key && lhs.imageURL == rhs.imageURL
    }
}
