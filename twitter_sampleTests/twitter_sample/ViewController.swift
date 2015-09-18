//
//  ViewController.swift
//  twitter_sample
//
//  Created by NAGAMINE HIROMASA on 2015/08/16.
//  Copyright (c) 2015年 Hiromasa Nagamine. All rights reserved.
//

import UIKit
import Accounts

class ViewController: UIViewController {
    
    var accountStore = ACAccountStore()   // 追加
    var twAccount = ACAccount?()          // 追加

    @IBOutlet var loginButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func tappedLoginButton(sender: AnyObject) {
        selectTwitterAccountsFromDevice()
    }
    
    /* iPhoneに設定したTwitterアカウントの選択画面を表示する */
    func selectTwitterAccountsFromDevice(){
        let accountType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        accountStore.requestAccessToAccountsWithType(accountType, options: nil) { (granted:Bool, aError:NSError?) -> Void in
            
            if let error = aError {
                println("Error! - \(error)")
                return;
            }
            
            if !granted {
                println("Cannot access to account data")
                return;
            }
            
            let accounts = self.accountStore.accountsWithAccountType(accountType) as! [ACAccount]
            self.showAndSelectTwitterAccountWithSelectionSheets(accounts)
        }
    }
    
    /* アカウントを選択したあと、タイムライン画面へ遷移する処理 */
    func showAndSelectTwitterAccountWithSelectionSheets(accounts: [ACAccount]) {
        
        var alertController = UIAlertController(title: "Select Account", message: "Please select twitter account", preferredStyle: .ActionSheet)
        
        for account in accounts {
            alertController.addAction(UIAlertAction(title: account.username, style: .Default, handler: { (action) -> Void in
                self.twAccount = account
                self.performSegueWithIdentifier("segueTimelineViewController", sender: nil)
            }))
        }
        
        let CanceledAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(CanceledAction)

        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueTimelineViewController" {
            var vc = segue.destinationViewController as! TimelineViewController
            vc.twAccount = self.twAccount!
        }
    }
    
}

