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
            Common.ud.set(imageUrl, forKey: Common.USERDATA_USER_IMAGE)
            
            let userData = [
                Common.USERDATA_USERID : user.userID,
                Common.USERDATA_IDTOKEN : user.authentication.idToken,
                Common.USERDATA_GIVEN_NAME : user.profile.givenName,
                Common.USERDATA_FAMILY_NAME : user.profile.familyName,
                Common.USERDATA_EMAIL : user.profile.email
                ] as [String : Any]
            
            Common.ud.set(userData, forKey: Common.USER_REGISTER_DATA)
            Common.ud.set(true, forKey: Common.DID_SIGNIN)
            Common.ud.synchronize()
            
            dismiss(animated: true, completion: {
                logger.debug("")
            })
        }
    }
}
