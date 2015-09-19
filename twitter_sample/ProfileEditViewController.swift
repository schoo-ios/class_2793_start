//
//  ProfileEditViewController.swift
//  twitter_sample
//
//  Created by Hiromasa Nagamine on 9/1/15.
//  Copyright (c) 2015 Hiromasa Nagamine. All rights reserved.
//

import UIKit

class ProfileEditViewController: UIViewController {
    let serviceManager = TwitterServiceManager()

    @IBOutlet var userIcon: UIImageView!
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var twitterIdLabel: UILabel!
    @IBOutlet var profileMessageView: UITextView!
    @IBOutlet var sendButton: UIButton!
    
    var screenName:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sendButton.hidden = screenName! != serviceManager.myAccount().username
        
        serviceManager.fetchProfileByScreenName(screenName!, completion: {
            (success, result) -> Void in
            if success {
                let myStatus:Dictionary<String, AnyObject> = result!
                
                var userName = myStatus["name"] as! String
                var profileMessage = myStatus["description"]as! String
                var twitterID = "@"+self.screenName!
                var imageURL = NSURL(string: myStatus["profile_image_url"] as! String)
                var image = UIImage(data: NSData(contentsOfURL: imageURL!)!)
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.userNameLabel.text = userName
                    self.profileMessageView.text = profileMessage
                    self.twitterIdLabel.text = twitterID
                    self.userIcon.image = image
                })
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func tappedSendButton(sender: AnyObject) {
        
        serviceManager.sendProfile(profileMessageView.text, completion: { (success, message) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if success == false{
                    var alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .Default, handler:nil))
                    
                    self.presentViewController(alert, animated: true, completion:nil)
                }
                else {
                    self.navigationController?.popViewControllerAnimated(true)
                }
            })
        })
    }
}
