//
//  SettingsViewController.swift
//  SneakPic
//
//  Created by Michele Ruocco on 3/21/20.
//  Copyright © 2020 William. All rights reserved.
//

import UIKit
import FirebaseAuth

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func signOutPressed(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            print("signed out")
            moveToLoginStoryboard()
            
        } catch let signoutError as NSError {
            print("error signing out: ", signoutError.localizedDescription)
        }
        
    }
    
    func moveToLoginStoryboard() {
        let storyboard = UIStoryboard(name: "Login", bundle: .main)
        if let initialViewController = storyboard.instantiateInitialViewController() {
            self.view.window?.rootViewController = initialViewController
            self.view.window?.makeKeyAndVisible()
        }
    }

}
