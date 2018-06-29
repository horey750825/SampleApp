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

enum GetDataError: Error {
    case getAgeProblem
    case getSexProblem
}

public protocol HealthDelegate {
    func finishPersonalProfile()
}

class HealthManager: NSObject {
    static let sharedInstance: HealthManager = HealthManager()
    
    var delegate : HealthDelegate?
    let healthStore = HKHealthStore()

    var personalProfile = PersonalProfile()
    var didGetProfile = false
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
    
    func getSex() throws -> HKBiologicalSex? {
        do {
            let sex = try healthStore.biologicalSex()
            let unwrapSex = sex.biologicalSex
            return unwrapSex
        } catch {
            logger.debug("\(error.localizedDescription)")
            throw GetDataError.getSexProblem
        }
    }
    
    func getAge() throws -> Int {
        do {
            let birth = try healthStore.dateOfBirthComponents()
            let today = Date()
            let calendar = Calendar.current
            let todayDate = calendar.dateComponents([.year], from: today)
            let thisYear = todayDate.year!
            let age = thisYear - birth.year!
            return age
        } catch {
            throw GetDataError.getAgeProblem
        }
    }
    
    func getPersonalProfile() {
        var count = personalProfile.dataCount
        
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
                logger.debug("getHeight error = \(error!.localizedDescription)")
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
                logger.debug("getWeight error = \(error!.localizedDescription)")
            }
        }
        
        do {
            let age = try self.getAge()
            self.personalProfile.age = age
            count -= 1
            if count == 0 {
                self.delegate?.finishPersonalProfile()
            }
        } catch {
            logger.debug("getAgeProblem")
        }
        
        do {
            let biologicalSex = try self.getSex()
            if let sex = biologicalSex {
                switch sex {
                case .male:
                    self.personalProfile.sex = "Male"
                case .female:
                    self.personalProfile.sex = "Female"
                default:
                    self.personalProfile.sex = "notset"
                }
            } else {
                self.personalProfile.sex = "notset"
            }
            count -= 1
            if count == 0 {
                self.delegate?.finishPersonalProfile()
            }
        } catch {
            logger.debug("getSexProblem")
        }
        
    }
}
