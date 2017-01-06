//
//  ViewController.swift
//  MySocialApp
//
//  Created by Forest Plasencia on 1/5/17.
//  Copyright © 2017 Forest Plasencia. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase

class SignInVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func facebookBtnTapped(_ sender: Any) {
        
        let facebookLogin = FBSDKLoginManager()
        
        // Facebook auth
        facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if error != nil {
                print("FOREST: Unable to authenticate with Facebook - \(error)")
            } else if result?.isCancelled == true {
                print("FOREST: User cancelled facebook authentication")
            } else {
                print("FOREST: Successfully authenticated with facebook")
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                self.firebaseAuth(credential)
            }
        }
    }
    
    // Firebase auth
    func firebaseAuth(_ credential: FIRAuthCredential) {
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if error != nil {
                print("FOREST: Unable to authenticate with Firebase - \(error)")
            } else {
                print("FOREST: Successfully authenticated with Firebase")
            }
        })
    }

    
}

