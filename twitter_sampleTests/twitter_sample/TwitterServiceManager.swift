//
//  TwitterServiceManager.swift
//  twitter_sample
//
//  Created by Hiromasa Nagamine on 9/1/15.
//  Copyright (c) 2015 Hiromasa Nagamine. All rights reserved.
//

import UIKit
import Accounts
import Social

class TwitterServiceManager: NSObject {
    var accountStore = ACAccountStore()
    var accounts:[ACAccount]?
    var tweets = []

    func setId(id:String)
    {
        NSUserDefaults.standardUserDefaults().setValue(id, forKey: "TwitterUserListIndex")
    }
    
    func myId() -> String
    {
        return NSUserDefaults.standardUserDefaults().objectForKey("TwitterUserListIndex")! as! String
    }
    
    func myAccount() -> ACAccount
    {
        return self.accountStore.accountWithIdentifier(myId())
    }

    func accountList() -> [ACAccount]
    {
        return accounts!
    }

    //  Twitter APIを使ってタイムラインを取得しtweetsに保存する
    func fetchTimeline(completion:(success:Bool) -> Void)
    {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        let URL = NSURL(string: "https://api.twitter.com/1.1/statuses/home_timeline.json")

        let request = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .GET, URL: URL, parameters: nil)
        request.account = myAccount()

        UIApplication.sharedApplication().networkActivityIndicatorVisible = true

        request.performRequestWithHandler { (data, response, error:NSError?) -> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false

            if error != nil {
                println("Fetching Error: \(error)")
                completion(success: false)
                return
            }

            var tweetResponse: AnyObject? =  NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments, error: nil)

            if let tweetDict = tweetResponse as? Dictionary<String, AnyObject>{
                completion(success: false)
                return
            }

            self.tweets = tweetResponse as! NSArray
            completion(success: true)
        }
    }

    func fetchAccountsList(completion:(success:Bool) -> Void)
    {

        let accountType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        accountStore.requestAccessToAccountsWithType(accountType, options: nil) { (granted:Bool, aError:NSError?) -> Void in
            
            if let error = aError {
                println("Error! - \(error)")
                completion(success: false)
                return;
            }
            
            if !granted {
                println("Cannot access to account data")
                completion(success: false)
                return;
            }

            self.accounts = (self.accountStore.accountsWithAccountType(accountType) as? [ACAccount])!
            completion(success: true)
        }
    }

    func sendTweet(tweet:String, completion:(success:Bool) -> Void)
    {
        let URL = NSURL(string: "https://api.twitter.com/1.1/statuses/update.json")

        if count(tweet) <= 0 {
//            var alert = UIAlertController(title: "Error", message: "Please input text", preferredStyle: UIAlertControllerStyle.Alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler:nil))
//            self.presentViewController(alert, animated: true, completion:nil)
            completion(success: false)
            return
        }

        var params = ["status": tweet]

        // リクエストを生成
        let request = SLRequest(forServiceType: SLServiceTypeTwitter,
            requestMethod: .POST,
            URL: URL,
            parameters: params)

        // 取得したアカウントをセット
        request.account = myAccount()

        // APIコールを実行
        request.performRequestWithHandler { (responseData, urlResponse, error) -> Void in

            if error != nil {
                println("error is \(error)")
                completion(success: false)
            }
            else {
                // 結果の表示
                let result = NSJSONSerialization.JSONObjectWithData(responseData, options: .AllowFragments, error: nil) as! NSDictionary
                completion(success: true)
                println("result is \(result)")
            }
        }
    }
}
