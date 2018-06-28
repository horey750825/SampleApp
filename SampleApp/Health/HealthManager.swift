//
//  HealthManager.swift
//  SampleApp
//
//  Created by Nikki on 2018/06/15.
//  Copyright © 2018年 Nikki. All rights reserved.
//

import UIKit
import HealthKit

struct PersonalProfile {
    var height : Double = 0
    var weight : Double = 0
    var sex: String?
    var age: Int?
    
    let dataCount = 4
    
    func toString() -> String {
        var result = "Personal "
        result += "height = \(height) cm\n"
        result += "weight = \(weight) cm\n"
        result += "age = \(age!)\n"
        result += "sex = \(sex!)"
        return result
    }
}

public protocol HealthDelegate {
    func finishPersonalProfile()
}

class HealthManager: NSObject {
    static let sharedInstance: HealthManager = HealthManager()
    
    var delegate : HealthDelegate?
    let healthStore = HKHealthStore()

    var personalProfile = PersonalProfile()
    let profileCount = 2
    let bodyHeight = HKObjectType.quantityType(forIdentifier: .height)!
    let bodyMass = HKObjectType.quantityType(forIdentifier: .bodyMass)!
    let biologicalSex = HKObjectType.characteristicType(forIdentifier: .biologicalSex)!
    let personalAge = HKObjectType.characteristicType(forIdentifier: .dateOfBirth)!
    
    
    private override init() {
        super.init()
    }
    
    func authorizeHealthKit(completion: @escaping (AuthResult) -> Void) {
        let toRead : Set<HKObjectType> = [
            bodyHeight,
            bodyMass,
            biologicalSex,
            personalAge
        ]
        let toShare = Set(arrayLiteral: HKSampleType.quantityType(forIdentifier: .height)!,
                          HKSampleType.quantityType(forIdentifier: .bodyMass)!)
        if !HKHealthStore.isHealthDataAvailable() {
            logger.debug()
            return
        }
        
        healthStore.requestAuthorization(toShare: toShare, read: toRead) { (success, error) in
            if success {
                completion(.success(success))
            } else {
                completion(.failure(error))
            }
        }
    }
    
    func getHeight(completion: @escaping (Bool, Double?, Error?) -> Void) {
        let type = HKSampleType.quantityType(forIdentifier: .height)!
        let query = HKSampleQuery(sampleType: type, predicate: nil, limit: 1, sortDescriptors: nil) { (sampleQuery, sampleData, error) in
            if let data = sampleData?.first as? HKQuantitySample {
                logger.debug("\(data.quantity)")
                completion(true, data.quantity.doubleValue(for: HKUnit.meterUnit(with: .centi)), error)
            } else {
                logger.debug("\(error.debugDescription)")
                completion(false, nil, error)
            }
        }
        healthStore.execute(query)
    }
    
    func getWeight(completion: @escaping (Bool, Double?, Error?) -> Void)  {
        let type = HKSampleType.quantityType(forIdentifier: .bodyMass)!
        let query = HKSampleQuery(sampleType: type, predicate: nil, limit: 1, sortDescriptors: nil) { (sampleQuery, sampleData, error) in
            if let data = sampleData?.first as? HKQuantitySample {
                logger.debug("\(data.quantity)")
                completion(true, data.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo)), error)
            } else {
                logger.debug("\(error.debugDescription)")
                completion(false, nil, error)
            }
        }
        healthStore.execute(query)
    }
    
    func getAgeSex() throws -> (age: Int, biologicalSex: HKBiologicalSex) {
        do {
            let birth = try healthStore.dateOfBirthComponents()
            let sex = try healthStore.biologicalSex()
            let today = Date()
            let calendar = Calendar.current
            let todayDate = calendar.dateComponents([.year], from: today)
            let thisYear = todayDate.year!
            let age = thisYear - birth.year!
            
            let unwrapSex = sex.biologicalSex
            
            logger.debug("age = \(age), sex = \(unwrapSex.rawValue)")
            return (age, unwrapSex)
        }
    }
    
    func getPersonalProfile() {
        var count = profileCount
        
        self.getHeight { (success, height, error) in
            if success {
                if let data = height {
                    self.personalProfile.height = data
                    count -= 1
                    if count == 0 {
                        self.delegate?.finishPersonalProfile()
                    }
                }
            } else {
                // error handler
            }
        }
        
        self.getWeight { (success, weight, error) in
            if success {
                if let data = weight {
                    self.personalProfile.weight = data
                    count -= 1
                    if count == 0 {
                        self.delegate?.finishPersonalProfile()
                    }
                }
            } else {
                // error handler
            }
        }
        
        do {
            let data = try self.getAgeSex()
            self.personalProfile.age = data.age
            switch data.biologicalSex {
            case .male:
                self.personalProfile.sex = "Male"
            case .female:
                self.personalProfile.sex = "Female"
            default:
                self.personalProfile.sex = "notset"
            }
        } catch {
            // error handler
        }
    }
}
