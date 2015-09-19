//
//  ViewController.swift
//  twitter_sample
//
//  Created by NAGAMINE HIROMASA on 2015/08/16.
//  Copyright (c) 2015年 Hiromasa Nagamine. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let serviceManager = TwitterServiceManager()
    
    @IBOutlet var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func tappedLoginButton(sender: AnyObject) {
        getTwitterAccountsFromDevice()
    }
    
    /* iPhoneに設定したTwitterアカウントの情報を取得する */
    func getTwitterAccountsFromDevice(){
        serviceManager.fetchAccountsList { (success, message) -> Void in
            if success == false {
                // 何かしらのエラーでアカウントリストの取得に失敗した場合
                var alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Default, handler:nil))
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    // Errorを表示
                    self.presentViewController(alert, animated: true, completion:nil)
                })
            } else {
                // アカウント情報の取得に成功
                var alertController = UIAlertController(title: "Select Account", message: "Please select twitter account", preferredStyle: .ActionSheet)
                
                for account in self.serviceManager.accountList() {
                    
                    alertController.addAction(UIAlertAction(title: account.username, style: .Default, handler: { (action) -> Void in
                        self.serviceManager.setId(account.identifier)
                        self.performSegueWithIdentifier("segueTimelineViewController", sender: nil)
                    }))
                    
                }
                
                // キャンセルボタンは何もせずにアクションシートを閉じる
                let CanceledAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
                alertController.addAction(CanceledAction)
                
                dispatch_async(dispatch_get_main_queue(), {
                    /* iPhoneに設定したTwitterアカウントの選択画面を表示する */
                    self.presentViewController(alertController, animated: true, completion: nil)
                })
            }
        }
    }
    
}

