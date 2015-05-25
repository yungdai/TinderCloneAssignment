//
//  LoginViewController.swift
//  TinderCloneAssignment
//
//  Created by Yung Dai on 2015-05-25.
//  Copyright (c) 2015 Yung Dai. All rights reserved.
//

import UIKit

import Parse

import FBSDKCoreKit
import FBSDKShareKit
import FBSDKLoginKit

class LoginViewController: UIViewController {
    let loginButton = FBSDKLoginButton()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    
        loginButton.center = self.view.center
        self.view.addSubview(loginButton)
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
