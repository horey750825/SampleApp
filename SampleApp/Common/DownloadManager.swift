//
//  ImageDownloadManager.swift
//  SampleApp
//
//  Created by Nikki on 2018/7/4.
//  Copyright © 2018年 Nikki. All rights reserved.
//

import UIKit

class DownloadManager: NSObject {

    static let sharedInstance: DownloadManager = DownloadManager()
    
    var cache = NSCache<AnyObject, AnyObject>()
    
    private override init() {
        super.init()
    }
    
    func imageForUrl(urlString: String, completion: @escaping(UIImage?, String) -> ()) {
        DispatchQueue.global().async {
            if let data = self.cache.object(forKey: urlString as AnyObject) as? Data {
                let image = UIImage(data: data)
                DispatchQueue.main.async {
                    logger.debug("get from cache")
                    completion(image, urlString)
                }
                return
            }
            
            let downloadTask = URLSession.shared.dataTask(with: URL(string: urlString)!) { (data, response, error) in
                guard error == nil else {
                    logger.debug("\(error!.localizedDescription)")
                    completion(nil, urlString)
                    return
                }
                
                guard let data = data else {
                    logger.debug("data = nil")
                    completion(nil, urlString)
                    return
                }
                
                let image = UIImage(data: data)
                self.cache.setObject(data as AnyObject, forKey: urlString as AnyObject)
                DispatchQueue.main.async {
                    logger.debug("get from download")
                    completion(image, urlString)
                }
                
            }
            
            downloadTask.resume()
        }
    }
    
}
