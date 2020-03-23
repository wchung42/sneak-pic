//
//  StorageReference+Post.swift
//  SneakPic
//
//  Created by Michele Ruocco on 3/19/20.
//  Copyright © 2020 William. All rights reserved.
//

import Foundation
import FirebaseStorage


extension StorageReference {
    static let dateFormatter = ISO8601DateFormatter()
    
    static func newPostImageReference() -> StorageReference {
        let timestamp = dateFormatter.string(from: Date())
        
        return Storage.storage().reference().child("images/\(timestamp).jpg")
    }
}
