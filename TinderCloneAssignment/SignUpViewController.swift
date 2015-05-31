//
//  SignUpViewController.swift
//  TinderCloneAssignment
//
//  Created by Yung Dai on 2015-05-30.
//  Copyright (c) 2015 Yung Dai. All rights reserved.
//

import UIKit
import Parse
import Bolts

import FBSDKCoreKit
import FBSDKShareKit
import FBSDKLoginKit

class SignUpViewController: UIViewController {
    var user = PFUser.currentUser()
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBAction func signUp(sender: AnyObject) {
        self.performSegueWithIdentifier("signedUp", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var FBSession = FBSDKAccessToken.currentAccessToken()
        var accessToken = FBSession?.tokenString
        let url = NSURL(string:"https://graph.facebook.com/me/picture?type=large&return_ssl_resources=1&access_token="+accessToken!)
        let urlRequest = NSURLRequest(URL: url!)
        NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            // print(data )
            var dataObject = data
            // convert the data and pass to image
            let image = UIImage(data: data)
            self.profileImage.image = image
            self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2;
            self.profileImage.clipsToBounds = true
            // save data to parse
            var FBReqest:FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
            FBReqest.startWithCompletionHandler({ (connection, result, error) -> Void in
                if !(error != nil) {
                    println("\(result)")
                    self.user!["first_name"] as! String
                    self.user!["name"] = result["name"] as! String
                    self.user!["gender"] = result["gender"] as! String
                    self.user!["email"] = result["email"] as! String
                    print(result["email"])
                    self.user!.save()
                }
            })
        }
    }
}