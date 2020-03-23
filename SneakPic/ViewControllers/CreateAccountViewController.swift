//
//  CreateAccountViewController.swift
//  SneakPic
//
//  Created by Michele Ruocco on 3/20/20.
//  Copyright © 2020 William. All rights reserved.
//

import UIKit
import Firebase

class CreateAccountViewController: UIViewController {
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var ref: DatabaseReference!
    
    
    var invalidCharacters: CharacterSet {
        let chars = NSMutableCharacterSet.alphanumeric()
        chars.addCharacters(in: "_-.")
        
        return chars as CharacterSet
    }
    
    let userRefPath: String = "test_users"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        
    }
    
    
    @IBAction func createAccount(_ sender: Any) {
        let email = emailTextField.text
        let password = passwordTextField.text
        let username = usernameTextField.text
        
        if email != nil && password != nil && username != nil {
            if username?.rangeOfCharacter(from: invalidCharacters) != nil {
                let usernameRef = ref.child("\(userRefPath)/usernames")
                usernameRef.observeSingleEvent(of: .value) { (snapshot) in
                    if snapshot.childSnapshot(forPath: username!.lowercased()).exists() {
                        self.signupErrorAlert("Username", message: "enter a new one")
                    } else {
                        Auth.auth().createUser(withEmail: email!, password: password!) { (result, error) in
                            if error != nil {
                                self.signupErrorAlert("problem", message: "\(error?.localizedDescription)")
                            } else {
                                self.ref.child("\(self.userRefPath)/usernames").child(username!.lowercased()).setValue(result!.user.uid)
                                
                                self.ref.child("\(self.userRefPath)/details").child(result!.user.uid).updateChildValues( ["email" : "\(email!)",
                                    "username": "\(username!)"])
                                
                                
                                // perform segue
                                print("perform segue to next storyboard")
                                self.moveToMainStoryboard()
                                
                            }
                        }
                    }
                }
            } else {
                self.signupErrorAlert("invalid username", message: "only letters, numbers, _, -, .")
            }
        }
    }
    
    func signupErrorAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

    
    func moveToMainStoryboard() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        if let initialViewController = storyboard.instantiateInitialViewController() {
            self.view.window?.rootViewController = initialViewController
            self.view.window?.makeKeyAndVisible()
        }
    }
    
}
