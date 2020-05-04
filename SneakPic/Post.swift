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
import CoreMotion

class Post {
    var key: String?
    let imageURL: String
    let imageHeight: CGFloat
    let creationDate: Date
    let locationCoordinates: CLLocationCoordinate2D
    let altitude: CLLocationDistance
    let position: CMQuaternion
    let userID: String
    init(imageURL: String, imageHeight: CGFloat, location: CLLocation, position: CMQuaternion, userID: String) {
        self.imageURL = imageURL
        self.imageHeight = imageHeight
        self.creationDate = Date()
        self.locationCoordinates = location.coordinate
        self.altitude = location.altitude
        self.position = position
        self.userID = userID
        
    }
    
    var dictValue: [String : Any] {
        let createdAgo = creationDate.timeIntervalSince1970
        
        return ["userID" : userID,
                "image_url" : imageURL,
                "image_height" : imageHeight,
                "created_at" : createdAgo,
                "latitude" : locationCoordinates.latitude,
                "longitude" : locationCoordinates.longitude,
                "altitude" : altitude,
                "position/x" : position.x,
                "position/y" : position.y,
                "position/z" : position.z,
                "position/w" : position.w]
    }
    
    init?(snapshot: DataSnapshot) {
        print(snapshot.value)
        guard let dict = snapshot.value as? [String : Any],
            let sensorDict = snapshot.childSnapshot(forPath: "position").value as? [String : Any],
            let userID = dict["userID"] as? String,
            let imageURL = dict["image_url"] as? String,
            let imageHeight = dict["image_height"] as? CGFloat,
            let createdAgo = dict["created_at"] as? TimeInterval,
            let lat = dict["latitude"] as? CLLocationDegrees,
            let long = dict["longitude"] as? CLLocationDegrees,
            let altitude = dict["altitude"] as? CLLocationDistance,
            let x = sensorDict["x"] as? Double,
            let y = sensorDict["y"] as? Double,
            let z = sensorDict["z"] as? Double,
            let w = sensorDict["w"] as? Double
        else {
            print("somethings wrong")
            return nil

        }
        
        self.key = snapshot.key
        self.imageURL = imageURL
        self.imageHeight = imageHeight
        self.creationDate = Date(timeIntervalSince1970: createdAgo)
        self.locationCoordinates = CLLocationCoordinate2D(latitude: lat, longitude: long)
        self.altitude = altitude
        self.position = CMQuaternion(x: x, y: y, z: z, w: w)
        self.userID = userID
    }
    
    static func ==(lhs: Post, rhs: Post) -> Bool {
        return lhs.key == rhs.key && lhs.imageURL == rhs.imageURL
    }
}
