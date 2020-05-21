//
//  CompareViewController.swift
//  SneakPic
//
//  Created by Michele Ruocco on 5/15/20.
//  Copyright © 2020 William. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import CoreLocation
import CoreMotion

class CompareViewController: UIViewController {
    
    var originalPhoto: UIImage?
    var newPhoto: AVCapturePhoto?
    var takenPhoto: UIImage?
    var originalPost: Post?
    
    var currentPosition: CLLocation?
    var photoPosition: attitude?
    var currentHeading: CLLocationDegrees?
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var segmentController: UISegmentedControl!
    
    @IBOutlet weak var originalLabelX: UILabel!
    @IBOutlet weak var originalLabelH: UILabel!
    @IBOutlet weak var originalLabelZ: UILabel!
    
    @IBOutlet weak var takenLabelX: UILabel!
    @IBOutlet weak var takenLabelH: UILabel!
    @IBOutlet weak var takenLabelZ: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        takenPhoto = UIImage(data: (newPhoto?.fileDataRepresentation())!)
        photoImageView.image = takenPhoto
        addLabels()
    }
    
    func addLabels() {
        originalLabelX.text = String(format: "X: %.4f", originalPost!.position.pitch)
        originalLabelZ.text = String(format: "Z: %.4f", originalPost!.position.yaw)
        originalLabelH.text = String(format: "H: %.3f", originalPost!.heading)
        
        takenLabelX.text = String(format: "X: %.4f", photoPosition!.pitch)
        takenLabelZ.text = String(format: "Z: %.4f", photoPosition!.yaw)
        takenLabelH.text = String(format: "H: %.3f", currentHeading!)
    }
    
    @IBAction func segmentChanged(_ sender: Any) {
        switch segmentController.selectedSegmentIndex {
        case 0:
            // original
            photoImageView.image = takenPhoto
        case 1:
            photoImageView.image = originalPhoto
        default:
            break
        }
    }
    
    func unwindToFeed() {
        performSegue(withIdentifier: "unwindToFeed", sender: self)
    }
    
    func savePhoto() {
        PostService.create(for: newPhoto!, location: currentPosition!, heading: currentHeading!, position: photoPosition!, locationID: originalPost?.LocationID)
    }
    @IBAction func donePressed(_ sender: Any) {
        let doneAlert = UIAlertController(title: "Save Photo?", message: "Would you like to upload your photo", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { (action) in
            self.savePhoto()
            self.unwindToFeed()
            
        }
        doneAlert.addAction(saveAction)
        let dontAction = UIAlertAction(title: "Dont Save", style: .destructive) { (action) in
            self.unwindToFeed()
        }
        doneAlert.addAction(dontAction)
        present(doneAlert, animated: true, completion: nil)
    }
}
