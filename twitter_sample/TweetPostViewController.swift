//
//  TweetPostViewController.swift
//  twitter_sample
//
//  Created by Hiromasa Nagamine on 8/30/15.
//  Copyright (c) 2015 Hiromasa Nagamine. All rights reserved.
//

import UIKit

class TweetPostViewController: UIViewController {
    let serviceManager = TwitterServiceManager()

    @IBOutlet var postField: UITextView!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var cancelButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func tappedSendButton(sender: AnyObject) {
        serviceManager.sendTweet(postField.text, completion: { (success, message) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                if success == false {
                    var alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .Default, handler:nil))
                    
                    self.presentViewController(alert, animated: true, completion:nil)
                }
                else {
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            })
        })
    }
    
    @IBAction func tappedCancelButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
