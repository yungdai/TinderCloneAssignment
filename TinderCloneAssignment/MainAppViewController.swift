//
//  MainAppViewController.swift
//  TinderCloneAssignment
//
//  Created by Yung Dai on 2015-05-25.
//  Copyright (c) 2015 Yung Dai. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation

// import the parse API to get the parse info
import Bolts
import Parse

class MainAppViewController: UIViewController {
    
    enum CardSelectionState{
        case NoSelection
        case MakingSelection
        case SwipingLeft
        case SwipedLeft
        case SwipingRight
        case SwipedRight
    }
    
    @IBOutlet weak var cardBackgroundView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var moreAboutMeBox: UITextView!
  
    
    
    var cardSelectionState:CardSelectionState = .NoSelection
    @IBOutlet weak var cardImage: UIImageView!
    
    var frame: CGRect!
    var xFromCenter:CGFloat = 0

    let locationManager = CLLocationManager()

    // assign the menu button to the viewcontroller

    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        frame = CGRectZero
        
//        cardImage.image = UIImage(named: "mario.jpg")
        // giving the image a circle style
        // add a corner radius to our image
        cardImage.layer.cornerRadius = cardImage.frame.size.width / 2
        cardImage.clipsToBounds = true

        if let currentUser = PFUser.currentUser(),
            let first_name = currentUser["first_name"] as? String,
            let urlString = currentUser["photo"] as? String,
            let moreAboutMe = currentUser["moreAboutMe"] as? String {
                self.nameLabel.text = first_name
                self.moreAboutMeBox.text = moreAboutMe
//
                // parse the photo URL into data for the UIImageView
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
                    let data = NSData(contentsOfURL: NSURL(string: urlString)!)
                    dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                        self.cardImage.image = UIImage(data: data!)
                    })
                })
                
        }
        // get the current location and sent to Parse
        PFGeoPoint.geoPointForCurrentLocationInBackground { (geoPoint:PFGeoPoint?, error:NSError?) -> Void in
            if let user = PFUser.currentUser() {
                user["currentLocation"] = geoPoint
                user.saveInBackground()
            }
            
        }
        
        

        // this code is for the SWRevealViewController Code API
        let revealVC = self.revealViewController()
        if revealVC != nil{
            menuButton.target = revealVC
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        stylemMyCard()
    }
    
    func stylemMyCard() {
        cardBackgroundView.layer.cornerRadius = 5
    
    }
    
    @IBAction func cardWasDragged(sender: UIPanGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.Began {
            frame = sender.view?.frame
        }
        let translation = sender.translationInView(self.view)
        // get was has been dragged
        var profile = sender.view!
        xFromCenter += translation.x
        var scale = min( 100 / abs(xFromCenter), 1)
        profile.center = CGPoint(x: profile.center.x + translation.x, y: profile.center.y)
        // reset translation
        sender.setTranslation(CGPointZero, inView: self.view)
        //rotate label
        var rotation:CGAffineTransform = CGAffineTransformMakeRotation(translation.x / 200)
        // stretch the current view
        var stretch:CGAffineTransform = CGAffineTransformScale(rotation, scale, scale)
        //imageView.transform = stretch
        // check if chosen or not chosen
        if profile.center.x <  100 {
            //println("not chose")
            cardSelectionState = .SwipingLeft
            // do nothing
            if profile.center.x <  20 {
                cardSelectionState = .SwipedLeft
            }
        } else {
            //println("chosen")
            cardSelectionState = .SwipingRight
            // Add to chosen list on parse
            if profile.center.x > 300 {
                cardSelectionState = .SwipedRight
            }
        }
        if sender.state == UIGestureRecognizerState.Ended {
            
            
            
            // set the label back
            //            profile.center = CGPointMake(view.bounds.width / 2, view.bounds.height / 2)
            //            // undo scale
            //            scale = max(abs(xFromCenter) / 100, 1)
            //            // undo rotation and stretch
            //            rotation = CGAffineTransformMakeRotation(0)
            //            // stretch the current view
            //            stretch = CGAffineTransformScale(rotation, scale, scale)
            //            // set image to original size after scaling
            
            UIView.animateWithDuration(0.3, animations:
                { () -> Void in
                    profile.frame = self.frame
                }, completion: {
                    (success) -> Void in
                    self.cardSelectionState = .NoSelection
            })
            
            
        }
        // TODO: load next image
        
    }
    // creating the function for wasDragged that passes in a UIPanGestureRecogniszer
   

    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }

}
