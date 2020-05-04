//
//  PostImageCell.swift
//  SneakPic
//
//  Created by Michele Ruocco on 3/22/20.
//  Copyright © 2020 William. All rights reserved.
//

import UIKit

class PostImageCell: UITableViewCell {
    
    @IBOutlet weak var postImageView: UIImageView!
    var post: Post?
    
    weak var delegate: PostImageCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func getDirections(_ sender: Any) {
        self.delegate?.getDirections(self, directionButtonTappedFor: post!)
    }
    
}

protocol PostImageCellDelegate: AnyObject {
    func getDirections(_ postImageCell: PostImageCell, directionButtonTappedFor post: Post)
}
