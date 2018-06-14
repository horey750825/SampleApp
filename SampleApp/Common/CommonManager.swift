//
//  CommonManager.swift
//  SampleApp
//
//  Created by Nikki on 2018/06/14.
//  Copyright © 2018年 Nikki. All rights reserved.
//

import UIKit

class CommonManager: NSObject {
    static let sharedInstance: CommonManager = CommonManager()
    
    let ud = UserDefaults.standard
    
    var imageForUser = UIImage()
    
    private override init() {
    }
    
}
