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

class MyInformationViewController: UIViewController, UITextViewDelegate {
    
//    let userParse = User.self

    
    // assigne the menu button to the viewcontroller
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var facebookImage: UIImageView!
    @IBOutlet weak var customImage: UIImageView!
    @IBOutlet weak var moreAboutMeTextBox: UITextView!
    
    @IBOutlet weak var bottomContraint: NSLayoutConstraint!
    @IBOutlet weak var parseUserName: UILabel!
    @IBOutlet weak var parseUserEmail: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // code to make the menu button work
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            
            // set up NSNotificationCenter for the keyboard listener functions
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide", name: UIKeyboardWillHideNotification, object: nil)

        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
    }
    
    func keyboardWillHide(notificaiton: NSNotification) {
        
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
    
    
    // enable and disable the UITextView box from being edited
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
    
    
    // move the UITextView up when you're about to type something into it.
    
//    func textViewDidBeginEditing(textView: UITextView) {
//        animateViewMoving(true, moveValue: 100)
//    }
//    
//    func textViewDidEndEditing(textView: UITextView) {
//        animateViewMoving(false, moveValue: 100)
//    }
//    
//    func animateViewMoving (up: Bool, moveValue: CGFloat) {
//        var movementDuration: NSTimeInterval = 0.3
//        var movement:CGFloat = (up? -moveValue: moveValue)
//        UIView.beginAnimations("animateView", context: nil)
//        UIView.setAnimationBeginsFromCurrentState(true)
//        UIView.setAnimationDuration(movementDuration)
//        self.view.frame = CGRectOffset(self.view.frame, 0, movement)
//        UIView.commitAnimations()
//    }
    
    
    
    
}
