//
//  LoginViewController.swift
//  SampleApp
//
//  Created by Nikki on 2018/06/14.
//  Copyright © 2018年 Nikki. All rights reserved.
//

import UIKit
import GoogleSignIn

class LoginViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {

    @IBOutlet weak var cancelButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        prepareSetting()
        // Do any additional setup after loading the view.
    }
    
    func prepareSetting() {
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: Google singin delegate

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            logger.debug("sign error = \(error.localizedDescription)")
        } else {
            //image
            let imageUrl = user.profile.imageURL(withDimension: 200)
            CommonManager.sharedInstance.ud.set(imageUrl, forKey: UserDataID.USER_IMAGE)
            let imageData = NSData(contentsOf: imageUrl!)
            CommonManager.sharedInstance.imageForUser = UIImage(data: imageData! as Data)!
            
            
            let userData = [
                UserDataID.USERID : user.userID,
                UserDataID.IDTOKEN : user.authentication.idToken,
                UserDataID.GIVEN_NAME : user.profile.givenName,
                UserDataID.FAMILY_NAME : user.profile.familyName,
                UserDataID.EMAIL : user.profile.email
                ] as [String : Any]
            
            CommonManager.sharedInstance.ud.set(userData, forKey: SettingID.USER_REGISTER_DATA)
            CommonManager.sharedInstance.ud.set(true, forKey: SettingID.DID_SIGNIN)
            
            dismiss(animated: true, completion: {
                logger.debug("")
//                ViewController().getHealthKitPermission()
                let alert = UIAlertController(title: "Login", message: "success")
                alert.show()
            })
        }
    }
}
