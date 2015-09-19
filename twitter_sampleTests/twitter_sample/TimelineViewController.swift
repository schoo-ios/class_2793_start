//
//  TimelineViewController.swift
//  twitter_sample
//
//  Created by NAGAMINE HIROMASA on 2015/08/16.
//  Copyright (c) 2015年 Hiromasa Nagamine. All rights reserved.
//

import UIKit
import Social
import Accounts

class TimelineViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource {

    let cellIdentifier = "tweetCell"
    var tweets = []
    
    var twAccount = ACAccount()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Timeline"
        self.refresh(self.refreshControl!)
    }
    
    override func viewDidAppear(animated: Bool) {
        if refreshControl!.refreshing {
            refreshControl!.beginRefreshing()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var aCell = tableView.dequeueReusableCellWithIdentifier("tweetCell") as? UITableViewCell
        
        if aCell == nil {
            aCell = UITableViewCell(style: .Default, reuseIdentifier: "tweetCell")
        }
        
        let tweet = tweets[indexPath.row] as! Dictionary<String,AnyObject>
        let text = tweet["text"] as! String
        let user = tweet["user"] as! Dictionary<String,AnyObject>
        let name = user["name"] as! String
        let image = UIImage(data: NSData(contentsOfURL: NSURL(string: user["profile_image_url"] as! String)!)!)
        
        let cell = aCell!
        cell.imageView?.image = image
        cell.textLabel?.text = text
        cell.detailTextLabel?.text = name
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("showTweetDetailViewController", sender: nil)
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50.0
    }
    
    //  Twitter APIを使ってタイムラインを取得しtweetsに保存する
    func fetchTimeline() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        let URL = NSURL(string: "https://api.twitter.com/1.1/statuses/home_timeline.json")
        
        let request = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .GET, URL: URL, parameters: nil)
        request.account = twAccount
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        request.performRequestWithHandler { (data, response, error:NSError?) -> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            self.refreshControl?.endRefreshing()
            
            if error != nil {
                println("Fetching Error: \(error)")
                return;
            }
            
            var tweetResponse: AnyObject? =  NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments, error: nil)
            
            if let tweetDict = tweetResponse as? Dictionary<String, AnyObject>{
                if let errors = tweetDict["errors"] as? Array<Dictionary<String,AnyObject>>{
                    var alert = UIAlertController(title: "Error", message: errors[0]["message"] as? String, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .Default, handler:nil))
                    self.presentViewController(alert, animated: true, completion:nil)
                }
                
                return
            }
            
            self.tweets = tweetResponse as! NSArray
            
            self.tableView.reloadData()
        }
    }

    @IBAction func tappedMenuButton(sender: AnyObject) {
        var alertController = UIAlertController(title: "Menu", message: nil, preferredStyle: .ActionSheet)
        

        alertController.addAction(UIAlertAction(title: "Edit Profile", style: .Default, handler: {
            (action) -> Void in
            self.performSegueWithIdentifier("showProfileEditViweController", sender: nil)
            
        }))
        alertController.addAction(UIAlertAction(title: "Logout", style: .Default, handler: {
            (action) -> Void in
            self.navigationController?.popViewControllerAnimated(true)
        }))

        
        let CanceledAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(CanceledAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showTweetPostViewController" {
            var vc = segue.destinationViewController as! TweetPostViewController
            vc.twAccount = self.twAccount
        }
    }
    
    @IBAction func refresh(sender: AnyObject) {
        fetchTimeline()
    }
}
