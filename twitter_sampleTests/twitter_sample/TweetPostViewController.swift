//
//  TweetPostViewController.swift
//  twitter_sample
//
//  Created by Hiromasa Nagamine on 8/30/15.
//  Copyright (c) 2015 Hiromasa Nagamine. All rights reserved.
//

import UIKit
import Accounts
import Social

class TweetPostViewController: UIViewController {

    @IBOutlet var postField: UITextView!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var cancelButton: UIButton!
    
    var twAccount = ACAccount()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func tappedSendButton(sender: AnyObject) {
        let URL = NSURL(string: "https://api.twitter.com/1.1/statuses/update.json")
    
        if count(postField.text) <= 0 {
            var alert = UIAlertController(title: "Error", message: "Please input text", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler:nil))
            self.presentViewController(alert, animated: true, completion:nil)
            
            return
        }
        
        var params = ["status": postField.text]
        
        // リクエストを生成
        let request = SLRequest(forServiceType: SLServiceTypeTwitter,
            requestMethod: .POST,
            URL: URL,
            parameters: params)
        
        // 取得したアカウントをセット
        request.account = twAccount
        
        // APIコールを実行
        request.performRequestWithHandler { (responseData, urlResponse, error) -> Void in
            
            if error != nil {
                println("error is \(error)")
            }
            else {
                // 結果の表示
                let result = NSJSONSerialization.JSONObjectWithData(responseData, options: .AllowFragments, error: nil) as! NSDictionary
                println("result is \(result)")
            }
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
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
