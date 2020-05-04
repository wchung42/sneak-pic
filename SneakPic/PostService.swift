//
//  PostService.swift
//  SneakPic
//
//  Created by Michele Ruocco on 3/18/20.
//  Copyright © 2020 William. All rights reserved.
//

import UIKit
import Firebase

import AVFoundation
import CoreLocation
import CoreMotion

struct PostService {
    static func create(for image: AVCapturePhoto, location: CLLocation, position: CMQuaternion) {
        let imageRef = StorageReference.newPostImageReference()
        StorageService.uploadImage(image, at: imageRef) { (downloadURL) in
            guard let downloadURL = downloadURL else {
                return
            }
            let urlString = downloadURL.absoluteString
            create(forURLString: urlString, aspectHeight: 600, location: location, position: position)

            
        }
    }
    
    private static func create(forURLString urlString: String, aspectHeight: CGFloat, location: CLLocation, position: CMQuaternion) {
        
        let currentUserID = Auth.auth().currentUser?.uid
        
        let post = Post(imageURL: urlString, imageHeight: aspectHeight, location: location, position: position, userID: currentUserID!)
        
        
        let dict = post.dictValue
        
        let postRef = Database.database().reference().child("photos").childByAutoId()
        
        postRef.updateChildValues(dict)
    }
    
}
