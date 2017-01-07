//
//  FeedVC.swift
//  MySocialApp
//
//  Created by Forest Plasencia on 1/5/17.
//  Copyright © 2017 Forest Plasencia. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import Firebase


class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageAdd: CircleView!
    @IBOutlet weak var captionField: CustomField!
    
    // Array of Post objects from Post.swift
    var posts = [Post]()
    var imagePicker: UIImagePickerController!
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    var imageSelected = false
    

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        // Initialize image picker
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        // Initialize Listeners for Firebase DB
        DataService.ds.REF_POSTS.observe(.value, with: { (snapshot) in
            // Emptys array upon change so posts arent duplicated
            self.posts = []
            
            // Gets children from Posts
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    print("SNAP: \(snap)")
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let post = Post(postKey: key, postData: postDict)
                        // Array of posts
                        self.posts.append(post)
                    }
                }
            }
            self.tableView.reloadData()
        })
        
        
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        
        
        return 1
    }
    
    // Number of cells to be created
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        

        
        return posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let post = posts[indexPath.row]

        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as? PostCell {
            
            // check if image exist in image cache
            if let img = FeedVC.imageCache.object(forKey: post.imageUrl as NSString) {
                cell.configureCell(post: post, img: img)
                return cell
            } else {
                cell.configureCell(post: post)
                return cell
            }

        } else {
            // Safety
            return PostCell()
        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            // set image of image button to selected image
            imageAdd.image = image
            imageSelected = true
        } else {
            print("FOREST: A Valid image was not selected")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    
    
    @IBAction func addImageTapped(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    @IBAction func postBtnTapped(_ sender: Any) {
        // Checks to make sure theres a caption
        guard let caption = captionField.text, caption != "" else {
            print("FOREST: Caption must be entered")
            return
        }
        // Checks to make sure theres an image
        guard let img = imageAdd.image, imageSelected == true else {
            print("FOREST: Image must be selected")
            return
        }
        // convert image to image data and comressing to pass to firebase storage
        if let imgData = UIImageJPEGRepresentation(img, 0.2) {
            
            // Unique ID for image
            let imgUid = NSUUID().uuidString
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg"
            
            // uploading image to firebase storage
            DataService.ds.REF_POST_IMAGES.child(imgUid).put(imgData, metadata: metadata) { (metadata, error) in
                if error != nil {
                    print("FOREST: Unable to upload image to firebase storage")
                } else {
                    print("FOREST: Image successfully uploaded to firebase storage")

                    let downloadURL = metadata?.downloadURL()?.absoluteString
                    if let url = downloadURL {
                        self.postToFirebase(imgUrl: url)
                    }
                    
                }
            }
            
        }
        
    }
    
    func postToFirebase(imgUrl: String) {
        let post: Dictionary<String, Any> = [
            "caption" : captionField.text!,
            "imageUrl" : imgUrl,
            "likes": 0
            ]
        
        // posts with auto generated unique ID
        let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
        firebasePost.setValue(post)
        
        captionField.text = ""
        imageSelected = false
        imageAdd.image = UIImage(named: "add-image")
        
        tableView.reloadData()
    }
    
    
    @IBAction func signOutTapped(_sender: AnyObject) {
        let keychainResult = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        print("FOREST: ID Removed from keychain \(keychainResult)")
        try! FIRAuth.auth()?.signOut()
        performSegue(withIdentifier: "goToSignIn", sender: nil)
        
    }
    
}
