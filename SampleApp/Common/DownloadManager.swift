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
    
    func shouldDownload(urlString: String, completion: @escaping(Bool) -> ()) {
        DispatchQueue.global().async {
            let md5String = urlString.md5!
            guard let url = URL(string: urlString) else {
                logger.debug("url = nil")
                completion(false)
                return
            }
            var request = URLRequest(url: url)
            request.httpMethod = "HEAD"
            let requestTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
                
                var isModified = true
                
                guard error == nil else {
                    logger.debug("\(error!.localizedDescription)")
                    completion(isModified)
                    return
                }
                
                guard let response = response else {
                    logger.debug("response = nil")
                    completion(isModified)
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse, let lastModifiedDate = httpResponse.allHeaderFields["Last-Modified"] as? String {
                    
                    
                }
                
            }
            
            requestTask.resume()
        }
    }
    
    func imageForUrl(urlString: String, completion: @escaping(UIImage?, String) -> ()) {
        DispatchQueue.global().async {
            let md5String = urlString.md5!
            if let data = self.cache.object(forKey: md5String as AnyObject) as? Data {
                let image = UIImage(data: data)
                DispatchQueue.main.async {
                    logger.debug("get from cache")
                    completion(image, urlString)
                }
                return
            }
            
            guard let url = URL(string: urlString) else {
                logger.debug("url = nil")
                completion(nil, urlString)
                return
            }
            
            let downloadTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
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
                self.cache.setObject(data as AnyObject, forKey: md5String as AnyObject)
                DispatchQueue.main.async {
                    logger.debug("get from download")
                    completion(image, urlString)
                }
                
            }
            
            downloadTask.resume()
        }
    }
    
}
