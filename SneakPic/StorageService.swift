//
//  StorageService.swift
//  SneakPic
//
//  Created by Michele Ruocco on 3/18/20.
//  Copyright © 2020 William. All rights reserved.
//

import UIKit
import AVFoundation
import FirebaseStorage

struct StorageService {
    // provide method for uploading images
    
    static func uploadImage(_ image: AVCapturePhoto, at reference: StorageReference, completion: @escaping (URL?) -> Void) {
        
        guard let imageData = image.fileDataRepresentation() else {
            return completion(nil)
        }
        
        reference.putData(imageData, metadata: nil) { (metadata, error) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return completion(nil)
            }
            
            reference.downloadURL { (url, error) in
                if let error = error {
                    assertionFailure(error.localizedDescription)
                    return completion(nil)
                }
                completion(url)
            }
        }
    }

}

