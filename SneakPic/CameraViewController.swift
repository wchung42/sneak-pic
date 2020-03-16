//
//  ViewController.swift
//  Sneak-Pic
//
//  Created by Michele Ruocco on 2/21/20.
//  Copyright © 2020 SneakPicProject. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class CameraViewController: UIViewController {

    
    var captureSession = AVCaptureSession()
    var photoOutput = AVCapturePhotoOutput()

    
    @IBOutlet weak var previewView: PreviewView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkAuthorizationCamera()

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
 
    func setupCaptureSession() {
        let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        guard
            let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice!), captureSession.canAddInput(videoDeviceInput)
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
        let photoSettings: AVCapturePhotoSettings
        if self.photoOutput.availablePhotoCodecTypes.contains(.hevc) {
            photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
        } else {
            photoSettings = AVCapturePhotoSettings()
        }
        photoSettings.flashMode = .auto
        photoSettings.isAutoStillImageStabilizationEnabled = self.photoOutput.isStillImageStabilizationSupported
        self.photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
    
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil else { print("Error capturing photo: \(error!)"); return }
        
        //saving photo to library
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else { return }
            
            PHPhotoLibrary.shared().performChanges({
                // add the captured photo file data as the main resource for the photos asset
                let creationRequest = PHAssetCreationRequest.forAsset()
                creationRequest.addResource(with: .photo, data: photo.fileDataRepresentation()!, options: nil)
            }, completionHandler: nil)
        }
    }
}
