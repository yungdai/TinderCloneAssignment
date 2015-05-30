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
        case SwipingLeft
        case SwipedLeft
        case SwipingRight
        case SwipedRight
    }
    
    @IBOutlet weak var cardBackgroundView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var moreAboutMeBox: UITextView!
    @IBOutlet weak var noButton: UIImageView!
    @IBOutlet weak var yesButton: UIImageView!
    
    var matchesMade = []
    var currentMatchIndex = 1
    var currentMatch: String?
    var listOfRequests = []
    var currentLocation: PFGeoPoint?
    var cardSelectionState:CardSelectionState = .NoSelection
    
    @IBOutlet weak var cardImage: UIImageView!
    
    var frame: CGRect!
    var xFromCenter:CGFloat = 0
    
    // assign the menu button to the viewcontroller

    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        frame = CGRectZero
        

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
                // parse the photo URL into data for the UIImageView
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
                    let data = NSData(contentsOfURL: NSURL(string: urlString)!)
                    dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                        self.cardImage.image = UIImage(data: data!)
                    })
                })
                
        }
        // get the current location and sent to Parse
        
        PFGeoPoint.geoPointForCurrentLocationInBackground { (geoPoint:PFGeoPoint?, error:NSError?) -> Void in if let user = PFUser.currentUser() {
            if (error != nil) {
                
            }
                self.currentLocation = geoPoint
            if let currentLocation = self.currentLocation {
                
            }
                user["currentLocation"] = geoPoint
                user.saveInBackground()
                self.checkForMatches(self.currentMatchIndex, aroundGeopoint: geoPoint!)
            }
            
        }
        
        // this code is for the SWRevealViewController Code API
        let revealVC = self.revealViewController()
        if revealVC != nil{
            menuButton.target = revealVC
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        }
    }
    
    // itterating through a bunch of people that match up
    func checkForMatches(iterator: Int, aroundGeopoint: PFGeoPoint) {
        
        // look into the User class object in Parse
        var kQuery = PFQuery(className: "_User")
        // tell parse to check their location and get the nearest users within 10km
        kQuery.whereKey("currentLocation", nearGeoPoint: aroundGeopoint, withinKilometers: 10)
        // ask parse  to get the User objects and process them using the parse API
        kQuery.findObjectsInBackgroundWithBlock { (users: [AnyObject]? , error: NSError?) -> Void in
            if (error != nil) {
                // take the current array of user objects and assign them to matchesMade
                self.matchesMade = users!
                let closestUser: AnyObject = self.matchesMade
                let name = closestUser["first_name"] as? String
                let photo = closestUser["photo"] as? String
                let photoURL = NSURL(string: photo!)
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
                    let imageData = NSData(contentsOfURL: photoURL!)
                    dispatch_sync(dispatch_get_main_queue(), {() -> Void in
                        self.cardImage.image = UIImage(data: imageData!)
                        self.cardImage.layer.cornerRadius = 8
                        self.cardImage.clipsToBounds = true
                        self.currentMatchIndex = iterator
                        self.currentMatch = closestUser.objectId
                    })
                })
            } else {
                println("Ooops there's an error")
                println(error?.description)
            }
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
            UIView.animateWithDuration(0.3, animations:
                { () -> Void in
                    profile.frame = self.frame
                }, completion: {
                    (completed) -> Void in
                    if (completed) {
                        
                        switch self.cardSelectionState {
                        case .SwipingLeft:
                            println("Swiping Left")
                        case .SwipedLeft:
                            self.nopeSelected() // need to create the nopeSelected function
                        case .SwipingRight:
                            println("Swiping Right")
                        case .SwipedRight:
                            self.okSelected() // need to create the okSelected function
                        default:
                            println("Oh NO!")
                        }
                        self.cardSelectionState = .NoSelection
                    }
            })
        }
        // TODO: load next image
        
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }

}
