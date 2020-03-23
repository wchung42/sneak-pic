//
//  LoginViewController.swift
//  SneakPic
//
//  Created by Michele Ruocco on 3/19/20.
//  Copyright © 2020 William. All rights reserved.
//

import UIKit
import Firebase


class LoginViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Auth.auth().currentUser != nil {
            print("Already Logged in")
            self.moveToMainStoryboard()
        }
    }
    
    func loginWithEmail(_ email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password, completion: {(user, error) in
            if error != nil {
                self.loginErrorAlert("opps", message: (error?.localizedDescription)!)
            } else {
                print("User logged in with email")
//                self.performSegue(withIdentifier: "USERLOGGEDIN", sender: nil)
                self.moveToMainStoryboard()
            }
            
        })
        
    }
    
     func getEmail(_ username:String, success:@escaping (_ email:String) -> Void, failure:@escaping (_ error:String?) -> Void) {
        let usernameRef =
            Database.database().reference().child("test_users/usernames/\(username.lowercased())")
        
        usernameRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let userId = snapshot.value as? String {
                let emailRef = Database.database().reference().child("test_users/details/\(userId)/email")
                
                emailRef.observeSingleEvent(of: .value, with: { (snapshot) in
                    if let email = snapshot.value as? String {
                        success(email)
                    } else {
                        failure("No email found for username '\(username)'.")
                    }
                }) { (error) in
                    failure("Email could not be found.")
                }
            } else {
                failure("No account found with username '\(username)'.")
            }
        }) { (error) in
            failure("Username could not be found.")
        }
    }
    
    func loginErrorAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    

//MARK: - IBActions
    
    @IBAction func loginPressed(_ sender: Any) {
        let userText = usernameTextField.text
        let passwText = passwordTextField.text
        
        if (userText?.contains("@"))! {
            loginWithEmail(userText!, password: passwText!)
        } else {
            print("using username")
            self.getEmail(userText!, success: { (email) in
                print(email)
                self.loginWithEmail(email, password: passwText!)
            }, failure: { (error) in
                self.loginErrorAlert("opps", message: error!)
            })
        }
    }
    
    func moveToMainStoryboard() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        if let initialViewController = storyboard.instantiateInitialViewController() {
            self.view.window?.rootViewController = initialViewController
            self.view.window?.makeKeyAndVisible()
        }
    }
    
    /*
     // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    
}
