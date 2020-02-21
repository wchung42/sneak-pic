//
//  PreviewView.swift
//  Sneak-Pic
//
//  Created by Michele Ruocco on 2/21/20.
//  Copyright © 2020 SneakPicProject. All rights reserved.
//

import UIKit
import AVFoundation

class PreviewView: UIView {
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
}
