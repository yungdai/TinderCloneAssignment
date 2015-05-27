//
//  MenuController.swift
//  TinderCloneAssignment
//
//  Created by Yung Dai on 2015-05-26.
//  Copyright (c) 2015 Yung Dai. All rights reserved.
//

import UIKit


// API setup
import Bolts
import Parse
import FBSDKCoreKit
import FBSDKShareKit
import FBSDKLoginKit

class MenuController: UITableViewController {
    @IBOutlet weak var logoutCell: UIView!
    
    @IBOutlet var logout: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // make sure that ONLY the showLoginScreen Segue runs this code to log the user out of parse and facebook
        if segue.identifier == "showLoginScreen" {
            PFUser.logOut()
            println("Parse User Logged Out")
            let loginManager = FBSDKLoginManager()
            loginManager.logOut()
            println("Facebook Logout")
            
        }
        
    }
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.

    
}
