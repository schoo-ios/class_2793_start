//
//  TweetDetailViewController.swift
//  twitter_sample
//
//  Created by Hiromasa Nagamine on 8/22/15.
//  Copyright (c) 2015 Hiromasa Nagamine. All rights reserved.
//

import UIKit

class TweetDetailViewController: UIViewController {
    var id: Int = -1
    var serviceManager = TwitterServiceManager()
    
    @IBOutlet var userIcon: UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet var screenName: UILabel!
    @IBOutlet var followerButton: UIButton!
    @IBOutlet var followingButton: UIButton!
    @IBOutlet var descriptionLabel: UILabel!
    
    override func viewDidLoad() {
        self.navigationItem.title = "Detail"
        
        var tweetInfo   = serviceManager.tweets[id] as! Dictionary<String, AnyObject>
        var userInfo    = tweetInfo["user"] as! Dictionary<String, AnyObject>
        var screenNameStr
        = userInfo["screen_name"] as! String
        
        serviceManager.fetchProfileByScreenName(screenNameStr, completion: { (success, result) -> Void in
            
            var profileUrlStr   = userInfo["profile_image_url"] as! String
            var profileUrl      = NSURL(string: profileUrlStr)!
            var imageData       = NSData(contentsOfURL: profileUrl)
            var image           = UIImage(data: imageData!)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.userIcon.image  = image
                self.name.text       = userInfo["name"] as? String
                self.screenName.text = userInfo["screen_name"] as? String
                self.descriptionLabel.text = tweetInfo["text"] as? String
            })
        })
        

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showFollowingViewController" {
            var vc = segue.destinationViewController as! FollowingViewController
            vc.serviceManager = self.serviceManager
        }
        if segue.identifier == "showFollowerViewController" {
            var vc = segue.destinationViewController as! FollowerViewController
            vc.serviceManager = self.serviceManager
        }
    }
}