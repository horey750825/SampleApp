//
//  FirstViewController.swift
//  SampleApp
//
//  Created by Nikki on 2018/06/08.
//  Copyright © 2018年 Nikki. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {

    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        logger.debug()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareSetting()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !CommonManager.sharedInstance.ud.bool(forKey: SettingID.DID_SIGNIN) {
            present(LoginViewController(), animated: true, completion: nil)
        } else {
            let imageUrl = CommonManager.sharedInstance.ud.url(forKey: UserDataID.USER_IMAGE)
            let imageData = NSData(contentsOf: imageUrl!)
            CommonManager.sharedInstance.imageForUser = UIImage(data: imageData! as Data)!
            
            //get user information
            HealthManager.sharedInstance.authorizeHealthKit(completion: { (success, error) in
                if success {
                    logger.debug("\(success)")
                    HealthManager.sharedInstance.getHeight { (success, height, error) in
                        if success {
                            logger.debug("\(height!)")
                        }
                    }
                } else {
                    if error != nil {
                        logger.debug(error.debugDescription)
                    }
                }
            })
        }
        
    }
    
    func prepareSetting() {
        setLabel()
    }
    
    func setLabel() {
        if let userData = CommonManager.sharedInstance.ud.dictionary(forKey: SettingID.USER_REGISTER_DATA) {
            var userName = userData[UserDataID.GIVEN_NAME] as! String
            userName += " "
            userName += userData[UserDataID.FAMILY_NAME] as! String
            userNameLabel.text = userName
        } else {
            userNameLabel.text = "Hi"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

