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


class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    // Array of Post objects from Post.swift
    var posts = [Post]()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
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
            cell.configureCell(post: post)
            return cell
        } else {
            // Safety
            return PostCell()
        }
        
    }
    
    
    
    
    @IBAction func signOutTapped(_sender: AnyObject) {
        let keychainResult = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        print("FOREST: ID Removed from keychain \(keychainResult)")
        try! FIRAuth.auth()?.signOut()
        performSegue(withIdentifier: "goToSignIn", sender: nil)
        
    }
    
}
