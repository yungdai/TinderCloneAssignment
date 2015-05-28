//
//  MyInformationViewController.swift
//  TinderCloneAssignment
//
//  Created by Yung Dai on 2015-05-26.
//  Copyright (c) 2015 Yung Dai. All rights reserved.
//

import UIKit
import AVFoundation


import Bolts
import Parse

class MyInformationViewController: UIViewController {
    
//    let userParse = User.self

    
    // assigne the menu button to the viewcontroller
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var facebookImage: UIImageView!
    @IBOutlet weak var customImage: UIImageView!
    @IBOutlet weak var moreAboutMeTextBox: UITextView!
    
    @IBOutlet weak var parseUserName: UILabel!
    @IBOutlet weak var parseUserEmail: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // code to make the menu button work
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let currentUser = PFUser.currentUser(),
            let name = currentUser["name"] as? String,
            let email = currentUser["email"] as? String,
            let urlString = currentUser["photo"] as? String,
            let moreAboutMe = currentUser["moreAboutMe"] as? String {
                self.parseUserName.text = name
                self.parseUserEmail.text = email
                self.moreAboutMeTextBox.text = moreAboutMe
                
                // parse the photo URL into data for the UIImageView
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
                    let data = NSData(contentsOfURL: NSURL(string: urlString)!)
                    dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                        self.facebookImage.image = UIImage(data: data!)
                    })
                })

        }
    }
    
    @IBAction func editInformationButtonPressed(sender: AnyObject) {
        self.moreAboutMeTextBox.editable = true
        
        
    }

    @IBAction func saveInformationButtonPressed(sender: AnyObject) {
        self.moreAboutMeTextBox.editable = false
        if let currentUser = PFUser.currentUser() {
            currentUser["moreAboutMe"] = self.moreAboutMeTextBox.text
            currentUser.saveInBackground()
        }
        println("User information is saved to Parse!")
    }
}
