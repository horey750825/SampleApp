//
//  MenuViewController.swift
//  SampleApp
//
//  Created by Nikki on 2018/06/08.
//  Copyright © 2018年 Nikki. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController, UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {


    @IBOutlet weak var labelUserName: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageViewUser: UIImageView!
    @IBOutlet weak var viewContener: UIView!
    @IBOutlet weak var tableViewProfile: UITableView!
    @IBOutlet weak var heightTableViewProfile: NSLayoutConstraint!
    @IBOutlet weak var heightViewContener: NSLayoutConstraint!
    
    let heightCell = 44
    let dataTitleList = [
        "Sex", "Age", "height(cm)", "weight(kg)", "Walking Distance Today(km)", "Walking Distance Everyday(km)"
    ]
    var dataList = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.delegate = self
        prepareSetting()
        dataList = HealthManager.sharedInstance.dataListForTableView
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // self.heightViewContener.constant = lastViewMaxY - scrollViewHeight
        let viewHeight = self.tableViewProfile.frame.maxY - self.scrollView.frame.size.height
        if viewHeight > 0 {
            self.heightViewContener.constant = viewHeight
        } else {
            self.heightViewContener.constant = 0
        }
    }
    
    func prepareSetting() {
        setLabel()
        setProfile()
        
        if let imageUrl = Common.ud.url(forKey: Common.USERDATA_USER_IMAGE) {
            let urlString = imageUrl.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            DownloadManager.sharedInstance.imageForUrl(urlString: urlString!) { (image, urlString) in
                guard let image = image else {
                    logger.debug("image = nil")
                    return
                }
                self.imageViewUser.image = image
            }
        }
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
        self.heightTableViewProfile.constant = CGFloat(heightCell * dataTitleList.count)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // #MARK - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    }
    
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
        return dataTitleList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        cell.textLabel?.text = dataTitleList[indexPath.row]
        if dataList.count == 0 {
            cell.detailTextLabel?.text = ""
        } else {
            cell.detailTextLabel?.text = dataList[indexPath.row]
        }
        if indexPath.row != 5 {
            cell.accessoryType = .none
            cell.selectionStyle = .none
        } else {
            cell.accessoryType = .detailButton
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

