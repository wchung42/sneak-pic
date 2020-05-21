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
    let position: attitude
    let userID: String
    let LocationID: String
    let heading: Double
    init(imageURL: String, imageHeight: CGFloat, location: CLLocation, position: attitude, userID: String, locationID: String, heading: Double) {
        self.imageURL = imageURL
        self.imageHeight = imageHeight
        self.creationDate = Date()
        self.locationCoordinates = location.coordinate
        self.altitude = location.altitude
        self.position = position
        self.userID = userID
        self.LocationID = locationID
        self.heading = heading
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
                "position/pitch" : position.pitch,
                "position/roll" : position.roll,
                "position/yaw" : position.yaw,
                "position/h" : heading,
                "locationID" : LocationID]
    }
    
    init?(snapshot: DataSnapshot) {
//        print(snapshot.value)
        guard let dict = snapshot.value as? [String : Any],
            let sensorDict = snapshot.childSnapshot(forPath: "position").value as? [String : Any],
            let userID = dict["userID"] as? String,
            let imageURL = dict["image_url"] as? String,
            let imageHeight = dict["image_height"] as? CGFloat,
            let createdAgo = dict["created_at"] as? TimeInterval,
            let lat = dict["latitude"] as? CLLocationDegrees,
            let long = dict["longitude"] as? CLLocationDegrees,
            let altitude = dict["altitude"] as? CLLocationDistance,
            let pitch = sensorDict["pitch"] as? Double,
            let roll = sensorDict["roll"] as? Double,
            let yaw = sensorDict["yaw"] as? Double,
            let h = sensorDict["h"] as? Double,
            let locID = dict["locationID"] as? String
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
        self.position = attitude(pitch: pitch, roll: roll, yaw: yaw)
        self.userID = userID
        self.LocationID = locID
        self.heading = h
    }
    
    static func ==(lhs: Post, rhs: Post) -> Bool {
        return lhs.key == rhs.key && lhs.imageURL == rhs.imageURL
    }
}

struct attitude {
    let pitch: Double
    let roll: Double
    let yaw: Double
}
