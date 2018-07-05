//
//  ImageDownloadManager.swift
//  SampleApp
//
//  Created by Nikki on 2018/7/4.
//  Copyright © 2018年 Nikki. All rights reserved.
//

import UIKit

enum GetHttpHeaderError: Error {
    case urlError
    case dataTaskError
    case responseError
    case httpResponseError
    case getLastModifiedError
}

class DownloadManager: NSObject {

    static let sharedInstance: DownloadManager = DownloadManager()
    
    var cache = NSCache<AnyObject, AnyObject>()
    var dataformat = DateFormatter()
    
    private override init() {
        super.init()
        dataformat.dateFormat = "EEEE, dd LLL yyyy hh:mm:ss zzz"
    }
    
    func shouldDownload(urlString: String, completion: @escaping(Bool, GetHttpHeaderError?) -> ()) {
        DispatchQueue.global().async {
            let md5String = urlString.md5!
            
            guard let url = URL(string: urlString) else {
                logger.debug("url = nil")
                completion(true, GetHttpHeaderError.urlError)
                return
            }
            var request = URLRequest(url: url)
            request.httpMethod = "HEAD"
            let requestTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
                                
                guard error == nil else {
                    logger.debug("\(error!.localizedDescription)")
                    completion(true, GetHttpHeaderError.dataTaskError)
                    return
                }
                
                guard let response = response else {
                    logger.debug("response = nil")
                    completion(true, GetHttpHeaderError.responseError)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    logger.debug("httpResponse = nil")
                    completion(true, GetHttpHeaderError.httpResponseError)
                    return
                }
                
                guard let lastModifiedDate = httpResponse.allHeaderFields["Last-Modified"] as? String else {
                    logger.debug("lastModifiedDate = nil")
                    completion(true, GetHttpHeaderError.getLastModifiedError)
                    return
                }
                
                logger.debug("Last-Modified \(lastModifiedDate)")
                
                if let newLastModifiedDate = self.dataformat.date(from: lastModifiedDate) {
                    if let savedLastModifiedDate = Common.ud.date(forKey: md5String) {
                        if newLastModifiedDate != savedLastModifiedDate {
                            completion(true, nil)
                        } else {
                            completion(false, nil)
                        }
                    } else {
                        Common.ud.set(newLastModifiedDate, forKey: md5String)
                        Common.ud.synchronize()
                        completion(true, nil)
                    }
                } else {
                    completion(true, GetHttpHeaderError.getLastModifiedError)
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
