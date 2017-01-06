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
import SwiftKeychainWrapper

class SignInVC: UIViewController {

    @IBOutlet weak var emailField: CustomField!
    @IBOutlet weak var passwordField: CustomField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    

    
    override func viewDidAppear(_ animated: Bool) {
        // Checks if user in keychain already exists
        if let _ = KeychainWrapper.standard.string(forKey: KEY_UID) {
            print("FOREST: ID Found in Keychain")
            performSegue(withIdentifier: "goToFeed", sender: nil)
        }
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
    
    // Firebase auth from facebook or other provider
    func firebaseAuth(_ credential: FIRAuthCredential) {
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if error != nil {
                print("FOREST: Unable to authenticate with Firebase - \(error)")
            } else {
                print("FOREST: Successfully authenticated with Firebase")
                if let user = user {
                    let userData = ["provider": credential.provider]
                    self.completeSignIn(id: user.uid, userData: userData)
                }
                
            }
        })
    }

    // Email Login / Sign-up
    @IBAction func signInTapped(_ sender: Any) {
        if let email = emailField.text, email != "", let pwd = passwordField.text, pwd != "" {
            FIRAuth.auth()?.signIn(withEmail: email, password: pwd, completion: { (user, error) in
                if error == nil {
                    print("FOREST: Email user authenticated with Firebase")
                    if let user = user {
                        let userData = ["provider": user.providerID]
                        self.completeSignIn(id: user.uid, userData: userData)
                    }
                    
                } else {
                    FIRAuth.auth()?.createUser(withEmail: email, password: pwd, completion: { (user, error) in
                        if error != nil {
                            print("FOREST: Unable to authenticate with Firebase using email \(error)")
                        } else {
                            print("FOREST: Successfully autheticated with Firesbase using email")
                            if let user = user {
                                let userData = ["provider": user.providerID]
                                self.completeSignIn(id: user.uid, userData: userData)
                            }
                        }
                    })
                }
            })
        }
        
    }
    
    func completeSignIn(id: String, userData: Dictionary<String, String>) {
        DataService.ds.createFirebaseDBUser(uid: id, userData: userData)
        let keychainResult = KeychainWrapper.standard.set(id, forKey: KEY_UID)
        print("FOREST: Data saved to keychain \(keychainResult)")
        performSegue(withIdentifier: "goToFeed", sender: nil)
    }
    
}

