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
    let profileInfoCount = HealthManager.sharedInstance.personalProfile.dataCount + 1
    
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
        let imageUrl = Common.ud.url(forKey: Common.USERDATA_USER_IMAGE)
        let imageData = NSData(contentsOf: imageUrl!)
        imageViewUser.image = UIImage(data: imageData! as Data)!
    }
    
    func setLabel() {
        if let userData = Common.ud.dictionary(forKey: Common.USER_REGISTER_DATA) {
            var userName = userData[Common.USERDATA_GIVEN_NAME] as! String
            userName += " "
            userName += userData[Common.USERDATA_FAMILY_NAME] as! String
            labelUserName.text = userName
        } else {
            labelUserName.text = "Hi"
        }
    }
    
    func setProfile() {
//        self.tableViewProfile.separatorStyle = UITableViewCellSeparatorStyle.none
        self.tableViewProfile.isScrollEnabled = false
        self.heightTableViewProfile.constant = CGFloat(heightCell * profileInfoCount)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x > 0 {
            scrollView.contentOffset.x = 0
    // #MARK - UITextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.isEmpty {
            return true
        }
        let currentText = textField.text ?? ""
        let replacementText = (currentText as NSString).replacingCharacters(in: range, with: string)
        return replacementText.isValidDouble(maxDecimalPlaces: 2)
    }
    
    // #MARK - UITableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profileInfoCount
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
            cell.textLabel?.text = "height(cm)"
            cell.detailTextLabel?.text = "\(HealthManager.sharedInstance.personalProfile.height)"
        case 3:
            cell.textLabel?.text = "weight(kg)"
            cell.detailTextLabel?.text = "\(HealthManager.sharedInstance.personalProfile.weight)"
        case 4:
            cell.textLabel?.text = "Walking Distance Today(km)"
            cell.detailTextLabel?.text = "\(HealthManager.sharedInstance.personalProfile.walkingDistance)"
        case 5:
            cell.textLabel?.text = "Walking Distance Everyday(km)"
            cell.detailTextLabel?.text = "\(HealthManager.sharedInstance.personalProfile.distanceEveryday)"
        default:
            cell.textLabel?.text = "Nikki"
            cell.detailTextLabel?.text = "0"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 5 {
            logger.debug()
            let alert = UIAlertController(title: "Set Distance", message: "Please set only by numberic(km)", preferredStyle: .alert)
            alert.addTextField(text: "", placeholder: "set the distnce(x.xx) you want", editingChangedTarget: nil, editingChangedSelector: nil)
            alert.textFields?.first?.delegate = self
            alert.addAction(title: "Cancel", style: .cancel, isEnabled: true, handler: nil)
            alert.addAction(title: "OK", style: .default, isEnabled: true, handler: { (action) in
                let inputText = alert.textFields!.first!.text!
                if !inputText.isEmpty {
                    HealthManager.sharedInstance.setDistanceEverydat(Double(inputText)!)
                }
                logger.debug("\(inputText)")
                tableView.reloadData()
            })
            alert.show()
        }
     }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(heightCell)
    }
}

