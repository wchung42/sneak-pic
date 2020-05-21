//
//  MapPins.swift
//  SneakPic
//
//  Created by Michele Ruocco on 4/4/20.
//  Copyright © 2020 William. All rights reserved.
//

import Foundation
import MapKit

class MapPin: NSObject, MKAnnotation {
    let post: Post
    var coordinate: CLLocationCoordinate2D { return post.locationCoordinates }
    
    init(point: Post) {
        self.post = point
        super.init()
    }
    
//    var title: String? { return post.creationDate.description }
//    var subtitle: String? { return "(\(post.locationCoordinates.latitude), \(post.locationCoordinates.longitude))" }
}
