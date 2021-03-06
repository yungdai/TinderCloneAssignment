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
import CoreLocation


class LoginViewController: UIViewController, FBSDKLoginButtonDelegate{
    let loginButton = FBSDKLoginButton()
    let permissions = ["public_profile", "email", "user_friends"]
    let userDefauls = NSUserDefaults.standardUserDefaults()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // push services test
        var push = PFPush()
        push.setMessage("Testing Push Notificaiton")
        push.sendPushInBackground()
        
        var currentUser = PFUser.currentUser()
        if currentUser?.sessionToken != nil {
            println("sending user to the main app screen because he's a current user")
            self.gotoMainScreen()
        } else {
            // Show the signup or login screen
            return
        }
        
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            println("User is already logged in go to the next viewcontroller")
        
        }

    }
    
    
    // impliment the Facebook delegates
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        println("User Logged In as a Facebook user")
        
        if ((error) != nil)
        {
            // Process error
        }
        else if result.isCancelled {
            // Handle cancellations
            println("user pressed the cancel button")
            
        } else {
            
            println("Putting the user to parse!")
            PFFacebookUtils.logInInBackgroundWithAccessToken(result.token, block: { (user: PFUser?, error: NSError?) -> Void in
                if let parseUser = user {
                    if parseUser.isNew {
                        println("User signed up and logged in through Facebook!")
                        
                    } else {
                        println("User logged in through Facebook!")
                        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "/me?fields=first_name,gender,email,name,picture.width(300).height(300)", parameters: nil)
                        graphRequest.startWithCompletionHandler({
                            (connection, result, error) -> Void in
                            if (error != nil)
                            {
                                // display the error message
                                println("Error: \(error)")
                            } else
                            {
                                // parsing the facebook data from the graph API and saving it to parse
                                // save the facebook name and email data to parseUser
                                parseUser["name"] = result["name"]
                                parseUser["email"] = result["email"]
                                parseUser["first_name"] = result["first_name"]
                                parseUser["gender"] = result["gender"]
                                
                                // test to make sure that the moreAboutMe column is empty before it's init
                                if parseUser["moreAboutMe"] != nil {
                                    println("didn't erase moreAboutme")
                                } else {
                                    parseUser["moreAboutMe"] = ""
                                    println("moreAboutMe reset")
                                }
                                
                                // sending the data to NSUserDefaults as well
                                
                                // sending the facebook picture to parse as a string
                                if let pictureResult = result["picture"] as? NSDictionary,
                                    pictureData = pictureResult["data"] as? NSDictionary,
                                    picture = pictureData["url"] as? String {
                                        parseUser["photo"] = picture
                                        
                                        
                                }
                                
                                // save the user's location to parse before you save the information
                                PFGeoPoint.geoPointForCurrentLocationInBackground { (geoPoint:PFGeoPoint?, error:NSError?) -> Void in
                                    if let user = PFUser.currentUser() {
                                        user["currentLocation"] = geoPoint
                                        user.saveInBackground()
                                    }
                                }
                                parseUser.saveInBackground()
                                println("Parse User Saved")
                            }
                        })
                        
                    }
                    self.gotoMainScreen()
                } else {
                    
                    
                    println("Uh oh. The user cancelled the Facebook login.")
                }
            })
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

}
