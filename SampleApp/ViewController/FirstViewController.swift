//
//  FirstViewController.swift
//  SampleApp
//
//  Created by Nikki on 2018/06/08.
//  Copyright © 2018年 Nikki. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController, HealthDelegate {

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
        HealthManager.sharedInstance.delegate = self
        
        if !CommonManager.sharedInstance.ud.bool(forKey: SettingID.DID_SIGNIN) {
            present(LoginViewController(), animated: true, completion: nil)
        } else {
            let imageUrl = CommonManager.sharedInstance.ud.url(forKey: UserDataID.USER_IMAGE)
            let imageData = NSData(contentsOf: imageUrl!)
            CommonManager.sharedInstance.imageForUser = UIImage(data: imageData! as Data)!
            
            //get user information
            HealthManager.sharedInstance.authorizeHealthKit(completion: { result in
                switch result {
                case .success(let granted) :
                    if granted {
                        logger.debug("access is granted")
                        if !HealthManager.sharedInstance.didGetProfile {
                            HealthManager.sharedInstance.getPersonalProfile()
                        }
                    } else {
                        logger.debug("access is denied")
                    }
                case .failure(let error) :
                    logger.debug("access error \(error!.localizedDescription)")
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

    // #MARK - HealthDelegate
    func finishPersonalProfile() {
        HealthManager.sharedInstance.didGetProfile = true
        logger.debug("\(HealthManager.sharedInstance.personalProfile.toString())")
    }
}

