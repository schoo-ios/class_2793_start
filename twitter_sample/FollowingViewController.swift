//
//  FollowingViewController.swift
//  twitter_sample
//
//  Created by Hiromasa Nagamine on 9/14/15.
//  Copyright (c) 2015 Hiromasa Nagamine. All rights reserved.
//

import UIKit

class FollowingViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource {
    var serviceManager = TwitterServiceManager()
    var id = 0
    
    override func viewDidLoad() {
    serviceManager.fetchFriendList(serviceManager.lastFetchedProfile["screen_name"] as! String, completion: { (success, result) -> Void in
            self.tableView.reloadData()
        })
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serviceManager.folloing.count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var aCell = tableView.dequeueReusableCellWithIdentifier("tweetCell") as? UITableViewCell
        
        if aCell == nil {
            aCell = UITableViewCell(style: .Default, reuseIdentifier: "tweetCell")
        }
        
        let folloing = serviceManager.folloing[indexPath.row] as! Dictionary<String,AnyObject>
        let name = folloing["name"] as! String
        let screenName = folloing["screen_name"] as! String
        let image = UIImage(data: NSData(contentsOfURL: NSURL(string: folloing["profile_image_url"] as! String)!)!)
        
        let cell = aCell!
        cell.imageView?.image = image
        cell.textLabel?.text = name
        cell.detailTextLabel?.text = screenName
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let folloing = serviceManager.folloing[indexPath.row] as! Dictionary<String,AnyObject>
        self.performSegueWithIdentifier("showProfileEditViweController", sender: folloing["screen_name"] as! String)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showProfileEditViweController" {
            var vc          = segue.destinationViewController as! ProfileEditViewController
            var screenName  = sender as! String
            vc.screenName   = screenName
        }
    }
}