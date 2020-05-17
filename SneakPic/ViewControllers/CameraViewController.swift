//
//  CameraViewController.swift
//  Sneak-Pic
//
//  Created by Michele Ruocco on 2/21/20.
//  Copyright © 2020 SneakPicProject. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import FirebaseStorage
import CoreLocation
import CoreMotion

class CameraViewController: UIViewController {

    let motionManager = CMMotionManager()
    var timer: Timer!
    // camera is a 4:3 aspect ratio
    var captureSession = AVCaptureSession()
    var photoOutput = AVCapturePhotoOutput()
    var capturePhoto: AVCapturePhoto?
    
    var photoPosition: CMQuaternion?
    var currentPosition: CLLocation?
    
    var locationManager: CLLocationManager!
    let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInTrueDepthCamera, .builtInDualCamera, .builtInWideAngleCamera], mediaType: .video, position: .unspecified)
//    var storage = Storage.storage()
    
    var post: Post?
    var isNewPost = false
    @IBOutlet weak var previewView: PreviewView!
    
    @IBOutlet weak var orignalImageView: UIImageView!
    
    @IBOutlet weak var currentX: UILabel!
    @IBOutlet weak var currentY: UILabel!
    @IBOutlet weak var currentZ: UILabel!
    @IBOutlet weak var currentLabel: UILabel!
    
    @IBOutlet weak var targetX: UILabel!
    @IBOutlet weak var targetY: UILabel!
    @IBOutlet weak var targetZ: UILabel!
    @IBOutlet weak var targetLable: UILabel!
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkAuthorizationCamera()
        
        if post == nil {
            isNewPost = true
        } else {
            isNewPost = false
            let imageURL = URL(string: post!.imageURL)
            orignalImageView.kf.setImage(with: imageURL)
        }
        
        setupLocationServices()
        addTargetParams()
        motionManager.startDeviceMotionUpdates(using: .xTrueNorthZVertical)
        motionManager.deviceMotionUpdateInterval = 0.5
        motionManager.showsDeviceMovementDisplay = true
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(gyroUpdate), userInfo: nil, repeats: true)
//        storage = Storage.storage()
//        let storageRef = storage.reference()
        
    }
    
    @objc func gyroUpdate() {
        if let deviceMotion = motionManager.deviceMotion {
//            print(deviceMotion.attitude.quaternion)
            
            
            self.currentX.text = "X: \(deviceMotion.attitude.quaternion.x)"
            self.currentY.text = "Y: \(deviceMotion.attitude.quaternion.y)"
            self.currentZ.text = "Z: \(deviceMotion.attitude.quaternion.z)"
        }
    }
    
    func addTargetParams() {
        if isNewPost {
            currentX.isHidden = true
            currentY.isHidden = true
            currentZ.isHidden = true
            currentLabel.isHidden = true
            
            targetX.isHidden = true
            targetY.isHidden = true
            targetZ.isHidden = true
            targetLable.isHidden = true
            
            orignalImageView.isHidden = true
        } else {
            currentX.isHidden = false
            currentY.isHidden = false
            currentZ.isHidden = false
            currentLabel.isHidden = false
            
            targetX.isHidden = false
            targetY.isHidden = false
            targetZ.isHidden = false
            targetLable.isHidden = false
            
            targetX.text = "X: \(post!.position.x)"
            targetY.text = "Y: \(post!.position.y)"
            targetZ.text = "Z: \(post!.position.z)"
            
            orignalImageView.isHidden = false
            orignalImageView.alpha = 0.4
            
        }
    }
    
    func setupLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.requestLocation()
            locationManager.requestWhenInUseAuthorization()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
    func checkAuthorizationCamera() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            self.setupCaptureSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    self.setupCaptureSession()
                }
            }
        case .denied:
            return
            
        case .restricted:
            return
        }
    }
 
    func bestDevice(in position: AVCaptureDevice.Position) -> AVCaptureDevice {
        let devices = self.discoverySession.devices
        guard !devices.isEmpty else { fatalError("Missing capture devices") }
        
        return devices.first(where: {device in device.position == position })!
    }
    func setupCaptureSession() {
        let videoDevice = bestDevice(in: .back)
        guard
            let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice), captureSession.canAddInput(videoDeviceInput)
            else { return }
        captureSession.addInput(videoDeviceInput)
        
        guard captureSession.canAddOutput(photoOutput) else { return }
        captureSession.sessionPreset = .photo
        captureSession.addOutput(photoOutput)
        captureSession.commitConfiguration()
        
        self.previewView.videoPreviewLayer.session = self.captureSession
        captureSession.startRunning()
    }

    @IBAction func didTapCaptureButton(_ sender: Any) {
        
        photoPosition = motionManager.deviceMotion?.attitude.quaternion
        currentPosition = locationManager.location
        timer.invalidate()
        motionManager.stopDeviceMotionUpdates()
        
        let photoSettings: AVCapturePhotoSettings
        if self.photoOutput.availablePhotoCodecTypes.contains(.jpeg) {
            photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        } else {
            photoSettings = AVCapturePhotoSettings()
        }
        photoSettings.flashMode = .auto
//        photoSettings.isAutoStillImageStabilizationEnabled = self.photoOutput.isStillImageStabilizationSupported
        self.photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        timer.invalidate()
        motionManager.stopDeviceMotionUpdates()
    }
    
    
// MARK: -Navigation
    func returnToFeed() {
        timer.invalidate()
        motionManager.stopDeviceMotionUpdates()
        performSegue(withIdentifier: "unwindToFeed", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is CompareViewController {
            print("going to compare")
            let vc = segue.destination as? CompareViewController
            vc?.originalPhoto = orignalImageView.image
            vc?.newPhoto = capturePhoto
            vc?.currentPosition = currentPosition
            vc?.photoPosition = photoPosition
            vc?.originalPost = post
        }
    }
}

extension CameraViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil else { print("Error capturing photo: \(error!)"); return }
        
        
        
        if isNewPost {
            PostService.create(for: photo, location: (locationManager?.location)!, position: photoPosition!, locationID: nil)
            
            let alert = UIAlertController(title: "Photo Saved", message: "Return to the Feed", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "return", style: .default, handler: { (action) in
                self.returnToFeed()
            }))
            present(alert, animated: true, completion: nil)
        } else {
            capturePhoto = photo
            performSegue(withIdentifier: "comparePhotos", sender: self)
        }
        
    
        
        
//        //saving photo to library
//        PHPhotoLibrary.requestAuthorization { status in
//            guard status == .authorized else { return }
//
//            PHPhotoLibrary.shared().performChanges({
//                // add the captured photo file data as the main resource for the photos asset
//                let creationRequest = PHAssetCreationRequest.forAsset()
//                creationRequest.addResource(with: .photo, data: photo.fileDataRepresentation()!, options: nil)
//            }, completionHandler: nil)
//        }
        
//        print(photo)
        
    }
}
