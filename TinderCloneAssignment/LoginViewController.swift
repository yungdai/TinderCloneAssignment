//
//  LoginViewController.swift
//  TinderCloneAssignment
//
//  Created by Yung Dai on 2015-05-25.
//  Copyright (c) 2015 Yung Dai. All rights reserved.
//

import UIKit

// Parse and Facebook API Setup

import Bolts
import Parse
import FBSDKCoreKit
import FBSDKShareKit
import FBSDKLoginKit


class LoginViewController: UIViewController, FBSDKLoginButtonDelegate{
    let loginButton = FBSDKLoginButton()
    let permissions = ["public_profile", "email", "user_friends"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // push services test
        var push = PFPush()
        push.setMessage("Testing Push Notificaiton")
        push.sendPushInBackground()
        
        var currentUser = PFUser.currentUser()
        if currentUser != nil {
            println("sending user to the main app screen because he's a current user")
            self.gotoMainScreen()
        } else {
            // Show the signup or login screen
            return
        }

    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        println("User Logged In")
        
        if ((error) != nil)
        {
            // Process error
        }
        else if result.isCancelled {
            // Handle cancellations
            println("user pressed the cancel button")
            
        } else {
            
            println("Putting the user to parse!")
            PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions as [AnyObject]) {
                (user: PFUser?, error: NSError?) -> Void in
                if let user = user {
                    if user.isNew {
                        println("User signed up and logged in through Facebook!")
                    } else {
                        println("User logged in through Facebook!")
                    }
//                    var userData = NSDictionary(objectsAndKeys: self.permissions)
                    
                    self.gotoMainScreen()
                } else {
                    println("Uh oh. The user cancelled the Facebook login.")
                }
                
            }
            println("Permission was allowed go to the next view")
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if result.grantedPermissions.contains("email")
            {
                println("access to user's email was granted")
                // print this out if the email was granted
               
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        println("User Logged Out")
        PFUser.logOut()
        // do I need this?
        var currentUser = PFUser.currentUser()
    }

    
    func gotoMainScreen(){
        self.performSegueWithIdentifier("showMainApp", sender: nil)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
