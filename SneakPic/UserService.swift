//
//  UserServices.swift
//  SneakPic
//
//  Created by Michele Ruocco on 3/22/20.
//  Copyright © 2020 William. All rights reserved.
//

import Foundation
import Firebase

struct UserService {
    static func posts(for user: User, completion: @escaping ([Post]) -> Void) {
        let ref = Database.database().reference().child("test_photos").child(user.uid)
        ref.observeSingleEvent(of: .value) { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else {
                return completion([])
            }
            
            let posts = snapshot.reversed().compactMap(Post.init)
            completion(posts)
        }
    }
}
