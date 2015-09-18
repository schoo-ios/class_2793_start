//
//  TwitterServiceManager.swift
//  twitter_sample
//
//  Created by Hiromasa Nagamine on 9/13/15.
//  Copyright (c) 2015 Hiromasa Nagamine. All rights reserved.
//

import UIKit
import Accounts
import Social

class TwitterServiceManager: NSObject {
    let keyForAccountID = "TwitterUserListIndex"
    
    var accountStore = ACAccountStore()
    var accounts:[ACAccount]?
    var tweets = []
    var folloing = []
    var follower = []
    var lastFetchedProfile:[String:AnyObject] = [:]
    
    func setId(id:String)
    {
        NSUserDefaults.standardUserDefaults().setValue(id, forKey: keyForAccountID)
    }
    
    func myId() -> String
    {
        return NSUserDefaults.standardUserDefaults().objectForKey(keyForAccountID) as! String
    }
    
    func myAccount() -> ACAccount
    {
        return accountStore.accountWithIdentifier(myId())
    }
    
    func accountList() -> [ACAccount]
    {
        return accounts!
    }
    
    //  Twitter APIを使ってタイムラインを取得する
    func fetchTimeline(completion:(success:Bool, message:String?) -> Void)
    {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        let URL = NSURL(string: "https://api.twitter.com/1.1/statuses/home_timeline.json")
        
        let request = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .GET, URL: URL, parameters: nil)
        request.account = myAccount()
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        request.performRequestWithHandler { (data, response, error:NSError?) -> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            
            if error != nil {
                completion(success: false, message: "Fetching Error: \(error)")
                return
            }
            
            var tweetResponse: AnyObject? =  NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments, error: nil)
            
            if let tweetDict = tweetResponse as? Dictionary<String, AnyObject>{
                completion(success: false, message:nil)
                return
            }
            
            self.tweets = tweetResponse as! NSArray
            completion(success: true, message:nil)
        }
    }
    
    func fetchAccountsList(completion:(success:Bool, message:String?) -> Void)
    {
        
        let accountType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        accountStore.requestAccessToAccountsWithType(accountType, options: nil) { (granted:Bool, aError:NSError?) -> Void in
            
            if let error = aError {
                completion(success: false, message: "Error! - \(error)")
                return;
            }
            
            if !granted {
                println("Cannot access to account data")
                completion(success: false, message: "Cannot access to account data")
                return;
            }
            
            self.accounts = (self.accountStore.accountsWithAccountType(accountType) as? [ACAccount])!
            completion(success: true, message:nil)
        }
    }

    func fetchProfileByScreenName(screenName:String, completion:(success:Bool, result:Dictionary<String,AnyObject>?) -> Void) {
        let URL = NSURL(string: "https://api.twitter.com/1.1/users/lookup.json?screen_name=" + screenName)
        
        let request = SLRequest(forServiceType: SLServiceTypeTwitter,
            requestMethod: .GET,
            URL: URL,
            parameters: nil)
        
        request.account = myAccount()
        
        request.performRequestWithHandler { (data, response, error:NSError?) -> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            
            if error != nil {
                println("Fetching Error: \(error)")
                return;
            }
            
            var tweetResponse: AnyObject? =  NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments, error: nil)
            
            if let tweetDict = tweetResponse as? Dictionary<String, AnyObject>{
                if let errors = tweetDict["errors"] as? Array<Dictionary<String,AnyObject>>{
                    completion(success: false, result: errors[0])
                }
                else {
                    completion(success: false, result: tweetDict)
                }
            }
            else {
                var result = tweetResponse as! Array<Dictionary<String, AnyObject>>
                self.lastFetchedProfile = result[0]
                completion(success: true, result: result[0])
            }
        }
    }
    
    func fetchFriendList(screenName:String, completion:(success:Bool, result:Array<AnyObject>?) -> Void) {
        let URL = NSURL(string: "https://api.twitter.com/1.1/friends/list.json?screen_name=" + screenName)
        
        let request = SLRequest(forServiceType: SLServiceTypeTwitter,
            requestMethod: .GET,
            URL: URL,
            parameters: nil)
        
        request.account = myAccount()
        
        request.performRequestWithHandler { (data, response, error:NSError?) -> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            
            if error != nil {
                println("Fetching Error: \(error)")
                return;
            }
            
            var tweetResponse: AnyObject? =  NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments, error: nil)
            
            if let tweetDict = tweetResponse as? Dictionary<String, AnyObject>{
                if let errors = tweetDict["errors"] as? Array<Dictionary<String,AnyObject>>{
                    completion(success: false, result: errors)
                }
                else {
                    self.folloing = tweetDict["users"] as! Array<AnyObject>
                    completion(success: true, result: self.folloing as Array<AnyObject>)
                }
            }
            else {
                completion(success: false, result: nil)
            }
        }

    }
    
    func fetchFollowerList(screenName:String, completion:(success:Bool, result:Array<AnyObject>?) -> Void) {
        let URL = NSURL(string: "https://api.twitter.com/1.1/followers/list.json?screen_name=" + screenName)
        
        let request = SLRequest(forServiceType: SLServiceTypeTwitter,
            requestMethod: .GET,
            URL: URL,
            parameters: nil)
        
        request.account = myAccount()
        
        request.performRequestWithHandler { (data, response, error:NSError?) -> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            
            if error != nil {
                println("Fetching Error: \(error)")
                return;
            }
            
            var tweetResponse: AnyObject? =  NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments, error: nil)
            
            if let tweetDict = tweetResponse as? Dictionary<String, AnyObject>{
                if let errors = tweetDict["errors"] as? Array<Dictionary<String,AnyObject>>{
                    completion(success: false, result: errors)
                }
                else {
                    self.follower = tweetDict["users"] as! Array<AnyObject>
                    completion(success: true, result: self.follower as Array<AnyObject>)
                }
            }
            else {
                completion(success: false, result: nil)
            }
        }
        
    }
    
    func sendTweet(message:String, completion:(success:Bool, message:String?) -> Void)
    {
        let URL = NSURL(string: "https://api.twitter.com/1.1/statuses/update.json")
        
        if count(message) <= 0 {
            completion(success: false, message:"Please input text")
            return
        }
        
        var params = ["status": message]
        
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
                completion(success: false, message:("error is \(error)"))
            }
            else {
                // 結果の表示
                let result = NSJSONSerialization.JSONObjectWithData(responseData, options: .AllowFragments, error: nil) as! NSDictionary
                println("result is \(result)")
                completion(success: true, message:nil)
            }
        }
    }
    
    func sendProfile(message:String, completion:(success:Bool, message:String?) -> Void)
    {
        let URL = NSURL(string: "https://api.twitter.com/1.1/account/update_profile.json")
        
        if count(message) <= 0 {
            completion(success: false, message:"Please input text")
            return
        }
        
        var params = ["description": message]
        
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
                completion(success: false, message:"error is \(error)")
            }
            else {
                // 結果の表示
                let result = NSJSONSerialization.JSONObjectWithData(responseData, options: .AllowFragments, error: nil) as! NSDictionary
                println("result is \(result)")
                completion(success: true, message:nil)
            }
        }
    }
}
