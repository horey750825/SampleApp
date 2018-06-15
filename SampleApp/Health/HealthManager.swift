//
//  HealthManager.swift
//  SampleApp
//
//  Created by Nikki on 2018/06/15.
//  Copyright © 2018年 Nikki. All rights reserved.
//

import UIKit
import HealthKit

class HealthManager: NSObject {
    static let sharedInstance: HealthManager = HealthManager()
    
    let healthStore = HKHealthStore()
    
    private override init() {
        super.init()
    }
    
    func authorizeHealthKit(completion: @escaping (Bool, Error?) -> Void) {
        let toRead = Set(arrayLiteral: HKObjectType.quantityType(forIdentifier: .height)!,
                         HKObjectType.quantityType(forIdentifier: .bodyMass)!)
        let toShare = Set(arrayLiteral: HKSampleType.quantityType(forIdentifier: .height)!,
                          HKSampleType.quantityType(forIdentifier: .bodyMass)!)
        if !HKHealthStore.isHealthDataAvailable() {
            logger.debug()
            return
        }
        
        healthStore.requestAuthorization(toShare: toShare, read: toRead) { (success, error) in
            completion(success, error)
        }
    }
    
    func getHeight(completion: @escaping (Bool, Double?, Error?) -> Void) {
        let type = HKSampleType.quantityType(forIdentifier: .height)!
        let query = HKSampleQuery(sampleType: type, predicate: nil, limit: 1, sortDescriptors: nil) { (sampleQuery, sampleData, error) in
            if let data = sampleData?.first as? HKQuantitySample {
                logger.debug("\(data.quantity)")
                completion(true, data.quantity.doubleValue(for: HKUnit.meter()), error)
            } else {
                logger.debug("\(error.debugDescription)")
                completion(false, nil, error)
            }
        }
        healthStore.execute(query)
    }
}
