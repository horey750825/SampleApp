//
//  SecondViewController.swift
//  SampleApp
//
//  Created by Nikki on 2018/06/08.
//  Copyright © 2018年 Nikki. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController, UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var heightScrollView: NSLayoutConstraint!
    @IBOutlet weak var labelUserName: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageViewUser: UIImageView!
    @IBOutlet weak var tableViewProfile: UITableView!
    @IBOutlet weak var heightTableViewProfile: NSLayoutConstraint!
    
    let heightCell = 44
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logger.debug("scroll view width = \(self.scrollView.frame.width), screenView = \(DeviceProfile.screenWidth)")
        self.scrollView.delegate = self
//        self.scrollView.bounces = true
//        self.scrollView.alwaysBounceVertical = true
        self.scrollView.contentSize = CGSize(width: DeviceProfile.screenWidth, height: Double(heightScrollView.constant))
        prepareSetting()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    func prepareSetting() {
        setLabel()
        setProfile()
        imageViewUser.image = CommonManager.sharedInstance.imageForUser
    }
    
    func setLabel() {
        if let userData = CommonManager.sharedInstance.ud.dictionary(forKey: SettingID.USER_REGISTER_DATA) {
            var userName = userData[UserDataID.GIVEN_NAME] as! String
            userName += " "
            userName += userData[UserDataID.FAMILY_NAME] as! String
            labelUserName.text = userName
        } else {
            labelUserName.text = "Hi"
        }
    }
    
    func setProfile() {
//        self.tableViewProfile.separatorStyle = UITableViewCellSeparatorStyle.none
        self.tableViewProfile.isScrollEnabled = false
        self.heightTableViewProfile.constant = 44 * 4
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x > 0 {
            scrollView.contentOffset.x = 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Sex"
            cell.detailTextLabel?.text = "\(HealthManager.sharedInstance.personalProfile.sex!)"
        case 1:
            cell.textLabel?.text = "Age"
            cell.detailTextLabel?.text = "\(HealthManager.sharedInstance.personalProfile.age!)"
        case 2:
            cell.textLabel?.text = "height"
            cell.detailTextLabel?.text = "\(HealthManager.sharedInstance.personalProfile.height)"
        case 3:
            cell.textLabel?.text = "weight"
            cell.detailTextLabel?.text = "\(HealthManager.sharedInstance.personalProfile.weight)"
        default:
            cell.textLabel?.text = "Nikki"
            cell.detailTextLabel?.text = "0"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(heightCell)
    }
}

