//
//  DataViewController.swift
//  SneakPic
//
//  Created by William on 2/18/20.
//  Copyright © 2020 William. All rights reserved.
//

import UIKit
import AVFoundation

class DataViewController: UIViewController {

    @IBOutlet weak var cameraView: UIView!
    
    @IBOutlet weak var dataLabel: UILabel!
    var dataObject: String = ""


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.dataLabel!.text = dataObject
    }


    @IBAction func imageCapture(_ sender: Any) {
    }
    
    @IBAction func rotateCamera(_ sender: Any) {
    }
}

