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

    var user = PFUser.currentUser()


    
    // setup the parse user
    var parseUser = PFUser.currentUser()

    @IBOutlet weak var errorMessage: UILabel!
    
    @IBAction func facebookButton(sender: UIButton) {
        self.errorMessage.alpha = 0
        if FBSDKAccessToken.currentAccessToken() != nil {
            //For debugging, when we want to ensure that facebook login always happens
            FBSDKLoginManager().logOut()
            //Otherwise do:
            return
        }
        FBSDKLoginManager().logInWithReadPermissions(self.permissions, handler: { (result:FBSDKLoginManagerLoginResult!, error:NSError!) -> Void in
            if error != nil {
                //According to Facebook:
                //Errors will rarely occur in the typical login flow because the login dialog
                //presented by Facebook via single sign on will guide the users to resolve any errors.
                FBSDKLoginManager().logOut()
                println("log out user")
                
            } else if result.isCancelled {
                // Handle cancellations
                FBSDKLoginManager().logOut()
                self.errorMessage.alpha = 1
                print("user cancelled login process")
                
            } else {
                // If you ask for multiple permissions at once, you
                // should check if specific permissions missing
                var allPermsGranted = true
                
                //result.grantedPermissions returns an array of _NSCFString pointers
                let perms = result.grantedPermissions as NSSet
                let grantedPermissions = perms.allObjects.map({$0})
                for permission in self.permissions {
                    /*if !contains(grantedPermissions, permission) {
                    allPermsGranted = false
                    break
                    }*/
                    println("permission were granted ")
                }
                if allPermsGranted {
                    // Do work
                    let fbToken = result.token.tokenString
                    let fbUserID = result.token.userID
                    self.performSegueWithIdentifier("signUpPage", sender: self)
                    NSLog("Do work section")
                }
            }
        })

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // push services test
        var push = PFPush()
        push.setMessage("Testing Push Notificaiton")
        push.sendPushInBackground()
        

        if parseUser?.sessionToken != nil {
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
    // TODO possibley delete the delagates
    
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
            // get the valid access token from facebook first
            PFFacebookUtils.logInInBackgroundWithAccessToken(result.token,  block: {
                (user: PFUser?, error: NSError?) -> Void in
                if let parseUser = user {
                    
                    
                    if parseUser.isNew {
                        println("User signed up and logged in through Facebook with the Access Token!")
                        
                    } else {
                        println("User logged in through Facebook!")
                        
                    }
                } else {

                    println("Uh oh. The user cancelled the Facebook login.")
                }
            })
            
            // then login with read permissions with the user and do the facebook Graph requests
            PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions as [AnyObject]) {
                (user: PFUser?, error: NSError?) -> Void in
                if let parseUser = user {
                    if parseUser.isNew {
                        println("User signed up and logged in through Facebook!")
                    } else {
                        println("User logged in through Facebook WITH PERMISSIONS!")
                        
                        
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
            }
            
            println("Putting the user to parse!")
            

        }

    
    }
    

    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        println("User Logged Out")
        PFUser.logOut()
        // do I need this?
        var currentUser = PFUser.currentUser()
    }

    
    func gotoMainScreen(){
        self.performSegueWithIdentifier("showMainApp", sender: self)
    }

}
