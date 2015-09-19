//
//  TimelineViewController.swift
//  twitter_sample
//
//  Created by NAGAMINE HIROMASA on 2015/08/16.
//  Copyright (c) 2015年 Hiromasa Nagamine. All rights reserved.
//

import UIKit

class TimelineViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource {
    let serviceManager = TwitterServiceManager()

    let cellIdentifier = "tweetCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Timeline"
        tableView.contentOffset.y = -self.refreshControl!.frame.size.height
        refresh(self.refreshControl!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func refresh(sender: AnyObject) {
        fetchTimeline()
    }
    
    @IBAction func tappedMenuButton(sender: AnyObject) {
        var alertController = UIAlertController(title: "Menu", message: "Select from following", preferredStyle: .ActionSheet)
        
        
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
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serviceManager.tweets.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var aCell = tableView.dequeueReusableCellWithIdentifier("tweetCell") as? UITableViewCell
        
        if aCell == nil {
            aCell = UITableViewCell(style: .Default, reuseIdentifier: "tweetCell")
        }
        
        let tweet = serviceManager.tweets[indexPath.row] as! Dictionary<String,AnyObject>
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
        self.performSegueWithIdentifier("showTweetDetailViewController", sender: indexPath)
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50.0
    }
    
    //  Twitter APIを使ってタイムラインを取得しtweetsに保存する
    func fetchTimeline() {
        self.refreshControl?.beginRefreshing()
        serviceManager.fetchTimeline { (success, message) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                self.refreshControl?.endRefreshing()
                if success == false {
                    // ツイート取得失敗
                    var alertController = UIAlertController(title: "Error", message: message, preferredStyle: .Alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler:nil))
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
                else {
                    // ツイートの更新
                    self.tableView.reloadData()
                }
            })
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showTweetDetailViewController" {
            var vc          = segue.destinationViewController as! TweetDetailViewController
            var indexPath   = sender as! NSIndexPath
            vc.id           = indexPath.row
            vc.serviceManager = serviceManager
        }
        if segue.identifier == "showProfileEditViweController" {
            var vc          = segue.destinationViewController as! ProfileEditViewController
            vc.screenName   = serviceManager.myAccount().username
        }
    }
}
