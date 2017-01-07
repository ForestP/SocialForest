//
//  PostCell.swift
//  MySocialApp
//
//  Created by Forest Plasencia on 1/6/17.
//  Copyright © 2017 Forest Plasencia. All rights reserved.
//

import UIKit

class PostCell: UITableViewCell {
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var postImg: UIImageView!
    @IBOutlet weak var caption: UITextView!
    @IBOutlet weak var likesLbl: UILabel!
    
    // Maybe dont need this?
    //var post: Post!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    
    func configureCell(post: Post) {
        self.caption.text = post.caption
        self.likesLbl.text = String(post.likes)
        
        
    }

}
