//
//  ProfileEditViewController.swift
//  twitter_sample
//
//  Created by Hiromasa Nagamine on 9/1/15.
//  Copyright (c) 2015 Hiromasa Nagamine. All rights reserved.
//

import UIKit

class ProfileEditViewController: UIViewController {
    let serviceManager = TwitterServiceManager()

    @IBOutlet var userIcon: UIImageView!
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var twitterIdLabel: UILabel!
    @IBOutlet var profileMessageLabel: UITextView!
    @IBOutlet var sendButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userNameLabel.text = "hiro_test_account"
        profileMessageLabel.text = "ツイッター始めました！まだ、右も左もわかりません。仲良くしてください！"
        twitterIdLabel.text = "@"+serviceManager.myAccount().username
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func tappedDoneButton(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
}
