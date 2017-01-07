//
//  PostCell.swift
//  MySocialApp
//
//  Created by Forest Plasencia on 1/6/17.
//  Copyright © 2017 Forest Plasencia. All rights reserved.
//

import UIKit
import Firebase

class PostCell: UITableViewCell {
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var postImg: UIImageView!
    @IBOutlet weak var caption: UITextView!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var likeImg: UIImageView!
    
    var post: Post!
    
    var likesRef: FIRDatabaseReference!

    
    override func awakeFromNib() {
        super.awakeFromNib()

        let tap = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
        tap.numberOfTapsRequired = 1
        likeImg.addGestureRecognizer(tap)
        likeImg.isUserInteractionEnabled = true
    }

    
    
    func configureCell(post: Post, img: UIImage? = nil) {
        self.post = post
        likesRef = DataService.ds.REF_USER_CURRENT.child("likes").child(post.postKey)

        self.caption.text = post.caption
        self.likesLbl.text = String(post.likes)
        
        // if an image is in cache set to that image
        if img != nil {
            self.postImg.image = img
        } else {
            let ref = FIRStorage.storage().reference(forURL: post.imageUrl)
            ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                    print("FOREST: Unable to download image from firebase storage")
                } else {
                    // convert imageUrl to image file
                    print("FOREST: Image downloaded from firebase storage")
                    if let imgData = data {
                        if let img = UIImage(data: imgData) {
                            self.postImg.image = img
                            FeedVC.imageCache.setObject(img, forKey: post.imageUrl as NSString)
                        }
                    }
                }
            })
        }
        
        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                // if null set like image to emtpy
                self.likeImg.image = UIImage(named: "empty-heart")
            } else {
                // if we get a result set image to filled heart
                self.likeImg.image = UIImage(named: "filled-heart")
            }
        })
    }
    
    func likeTapped(sender: UITapGestureRecognizer) {
        sender.isEnabled = false
        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                // if null set like image to filled heart
                self.likeImg.image = UIImage(named: "filled-heart")
                self.post.adjustLikes(addLike: true)
                self.likesRef.setValue(true)
            } else {
                // if we get a result set image to empty heart
                self.likeImg.image = UIImage(named: "empty-heart")
                self.post.adjustLikes(addLike: false)
                self.likesRef.removeValue()


            }
        })
        sender.isEnabled = true
    }
    
    
    
}
