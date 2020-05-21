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
    
    var photoPosition: attitude?
    var currentPosition: CLLocation?
    var currentHeading: CLLocationDegrees?
    
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
    @IBOutlet weak var currentH: UILabel!
    @IBOutlet weak var currentLabel: UILabel!
    
    @IBOutlet weak var targetX: UILabel!
    @IBOutlet weak var targetY: UILabel!
    @IBOutlet weak var targetZ: UILabel!
    @IBOutlet weak var targetH: UILabel!
    @IBOutlet weak var targetLable: UILabel!
    
    @IBOutlet weak var xImageView: UIImageView!
    @IBOutlet weak var yImageView: UIImageView!
    @IBOutlet weak var zImageView: UIImageView!
    @IBOutlet weak var hImageView: UIImageView!
    
    @IBOutlet weak var alphaSlider: UISlider!
    
    
    
    
    var oldX: Double?
    var oldY: Double?
    var oldZ: Double?
    var oldH: Double?
    
    var xAligned = false
    var yAligned = false
    var zAligned = false
    var hAligned = false
    override func viewDidLoad() {
        super.viewDidLoad()
        checkAuthorizationCamera()
        
        if post == nil {
            isNewPost = true
        } else {
            isNewPost = false
            let imageURL = URL(string: post!.imageURL)
            orignalImageView.kf.setImage(with: imageURL)
            oldX = post?.position.pitch
            oldY = post?.position.roll
            oldZ = post?.position.yaw
            oldH = post?.heading
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
            
            let x = deviceMotion.attitude.pitch
//            let y = deviceMotion.attitude.roll
            let z = deviceMotion.attitude.yaw
            
//            print("X: \(x)")
//            print("Y: \(y)")
            print("Z: \(z)")
            
            
            self.currentX.text = String(format: "X: %.4f", x)
//            self.currentY.text = "Y: \(y)"
            self.currentZ.text = String(format: "Z: %.4f", z)
            
            //calculate which direction needs to be turned in and set color of each
            if !isNewPost {
                
                // if x - oldX is negative need to tilt phone up
                // if y - oldY is negative need to tilt phone to the left
                // if z - oldZ is negative need to rotate phone to the left
                let xDiff = x - oldX!
//                let yDiff = y - oldY!
                let zDiff = z - oldZ!
                
                switch xDiff {
                case 0.05...2*Double.pi:
//                    print("tilt phone down")
                    xImageView.image = UIImage(systemName: "arrow.down")
                    xAligned = false
                case -2*Double.pi ... -0.05:
//                    print("tilt phone up")
                    xImageView.image = UIImage(systemName: "arrow.up")
                    xAligned = false
                default:
//                    print("Stop")
                    xImageView.image = UIImage(systemName: "xmark")
                    xAligned = true
                }
                
                switch zDiff {
                case 0.05...2*Double.pi:
//                    print("rotate phone right")
                    zImageView.image = UIImage(systemName: "arrow.clockwise")
                    zAligned = false
                case -2*Double.pi ... -0.05:
//                    print("rotate phone left")
                    zImageView.image = UIImage(systemName: "arrow.counterclockwise")
                    zAligned = false
                default:
//                    print("Stop")
                    zImageView.image = UIImage(systemName: "xmark")
                    zAligned = true
                }
                if xAligned && zAligned && hAligned {
                    takePhoto()
                }
            }
            
        }
    }
    
    
    
    func addTargetParams() {
        if isNewPost {
            currentX.isHidden = true
            currentY.isHidden = true
            currentZ.isHidden = true
            currentH.isHidden = true
            currentLabel.isHidden = true
            
            targetX.isHidden = true
            targetY.isHidden = true
            targetZ.isHidden = true
            targetH.isHidden = true
            targetLable.isHidden = true
            
            orignalImageView.isHidden = true
            alphaSlider.isHidden = true
            
            xImageView.isHidden = true
            yImageView.isHidden = true
            zImageView.isHidden = true
            hImageView.isHidden = true
        } else {
            currentX.isHidden = false
            currentY.isHidden = true
            currentZ.isHidden = false
            currentH.isHidden = false
            currentLabel.isHidden = false
            
            targetX.isHidden = false
            targetY.isHidden = true
            targetZ.isHidden = false
            targetH.isHidden = false
            targetLable.isHidden = false
            
            targetX.text = String(format: "X: %.4f", oldX!)
            targetY.text = "Y: \(oldY!)"
            targetZ.text = String(format: "Z: %.4f", oldZ!)
            targetH.text = String(format: "H: %.4f", oldH!)
            
            orignalImageView.isHidden = false
            orignalImageView.alpha = 0.4
            alphaSlider.isHidden = false
            
            xImageView.isHidden = false
            yImageView.isHidden = true
            zImageView.isHidden = false
            hImageView.isHidden = false
            
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
            locationManager.headingFilter = kCLHeadingFilterNone
            locationManager.startUpdatingHeading()
        }
    }
    
    @IBAction func sliderChanged(_ sender: Any) {
        orignalImageView.alpha = CGFloat(alphaSlider.value)
    }
    
//MARK: -Camera
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
            takePhoto()
    }
    
    func takePhoto() {
        let pitch = motionManager.deviceMotion?.attitude.pitch
        let roll = motionManager.deviceMotion?.attitude.roll
        let yaw = motionManager.deviceMotion?.attitude.yaw
        photoPosition = attitude(pitch: pitch!, roll: roll!, yaw: yaw!)
        currentPosition = locationManager.location
        currentHeading = locationManager.heading?.trueHeading
        timer.invalidate()
        motionManager.stopDeviceMotionUpdates()
        locationManager.stopUpdatingHeading()
        
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
        locationManager.stopUpdatingHeading()
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
            vc?.currentHeading = currentHeading
            vc?.photoPosition = photoPosition
            vc?.originalPost = post
        }
    }
}

// MARK: - Location Delegate
extension CameraViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !isNewPost {
            guard let h = manager.heading?.trueHeading else {
                print("error no heading")
                return
            }
            currentH.text = String(format: "H: %.3f", h)
            // if positive turn left
            let hDiff = h - oldH!
//            print(hDiff)
            switch hDiff {
            case 1.0 ... 360:
//                print("turn to the left")
                hImageView.image = UIImage(systemName: "arrow.left")
                hAligned = false
            case -360 ... -1.0:
//                print("turn to the right")
                hImageView.image = UIImage(systemName: "arrow.right")
                hAligned = false
            default:
//                print("Stop")
                hImageView.image = UIImage(systemName: "xmark")
                hAligned = true
            }
                
        }
        print("H: \(manager.heading?.headingAccuracy)")

    }
    func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        return true
    }
}

// MARK: -AVCaptureDelegate
extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil else { print("Error capturing photo: \(error!)"); return }
        
        
        
        if isNewPost {
            PostService.create(for: photo, location: (locationManager?.location)!, heading: (locationManager.heading?.trueHeading)!, position: photoPosition!, locationID: nil)
            
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
