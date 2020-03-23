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

struct PostService {
    static func create(for image: AVCapturePhoto) {
        let imageRef = StorageReference.newPostImageReference()
        StorageService.uploadImage(image, at: imageRef) { (downloadURL) in
            guard let downloadURL = downloadURL else {
                return
            }
            let urlString = downloadURL.absoluteString
            create(forURLString: urlString, aspectHeight: 600)
            
            
        }
    }
    
    private static func create(forURLString urlString: String, aspectHeight: CGFloat) {
        
        let currentUser = Auth.auth().currentUser
        
        let post = Post(imageURL: urlString, imageHeight: aspectHeight)
        
        let dict = post.dictValue
        
        let postRef = Database.database().reference().child("test_photos").child(currentUser!.uid).childByAutoId()
        
        postRef.updateChildValues(dict)
    }
    
}
