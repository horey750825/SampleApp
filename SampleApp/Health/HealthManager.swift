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
    var walkingDistance: Double = 0
    var distanceEveryday: Double = 0
    var didCheckDistanceEveryday = false
    
    let dataCount = 5
    
    func toString() -> String {
        var result = "Personal "
        result += "height = \(height) cm\n"
        result += "weight = \(weight) cm\n"
        result += "age = \(age!)\n"
        result += "sex = \(sex!)\n"
        result += "walking distance = \(walkingDistance)"
        return result
    }
}

enum GetDataError: Error {
    case getAgeProblem
    case getSexProblem
}

protocol HealthDelegate {
    func finishPersonalProfile()
}

class HealthManager: NSObject {
    static let sharedInstance: HealthManager = HealthManager()
    
    var delegate : HealthDelegate?
    let healthStore = HKHealthStore()

    var personalProfile = PersonalProfile()
    var didGetProfile = false
    var profileCount = 0
    let bodyHeight = HKObjectType.quantityType(forIdentifier: .height)!
    let bodyMass = HKObjectType.quantityType(forIdentifier: .bodyMass)!
    let biologicalSex = HKObjectType.characteristicType(forIdentifier: .biologicalSex)!
    let personalAge = HKObjectType.characteristicType(forIdentifier: .dateOfBirth)!
    let walkingDistance = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!
    
    
    private override init() {
        super.init()
        profileCount = personalProfile.dataCount
        let distance = Common.ud.double(forKey: Common.SET_WALKING_DISTANCE)
        if distance > 0 {
            personalProfile.didCheckDistanceEveryday = true
            personalProfile.distanceEveryday = distance
        }
    }
    
    func authorizeHealthKit(completion: @escaping (AuthResult) -> Void) {
        let toRead : Set<HKObjectType> = [
            bodyHeight,
            bodyMass,
            biologicalSex,
            personalAge,
            walkingDistance
        ]
        
        
        let toShare = Set(arrayLiteral: HKSampleType.quantityType(forIdentifier: .height)!,
                          HKSampleType.quantityType(forIdentifier: .bodyMass)!, HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning)!)
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
    
    func getDistance(completion:@escaping (Double, Error?) -> Void) {
        let distanceObject = HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning)
        
        let date = Date()
        let cal = Calendar(identifier: Calendar.Identifier.gregorian)
        let newDate = cal.startOfDay(for: date)
        let predicate = HKQuery.predicateForSamples(withStart: newDate, end: Date(), options: .strictStartDate)
        var interval = DateComponents()
        interval.day = 1
        
        let query = HKStatisticsCollectionQuery(quantityType: distanceObject!, quantitySamplePredicate: predicate, options: .cumulativeSum, anchorDate: newDate as Date, intervalComponents:interval)
        
        query.initialResultsHandler = {query, results, error -> Void in
            if error != nil {
                logger.debug(error.debugDescription)
                completion(-1, error)
                return
            }
            if results!.statistics().isEmpty {
                completion(0, nil)
            }
            for statistic in (results?.statistics())! {
                let caloriesUnit = HKUnit.meter()
                let quanlity = statistic.sumQuantity()
                let value = quanlity?.doubleValue(for: caloriesUnit)
                logger.debug("\(statistic.startDate) -- \(statistic.endDate) and \(String(describing: value))")
                completion(value!, nil)
            }
            
        }
        
        healthStore.execute(query)
        
    }

    func getPersonalProfile() {
        self.getHeight { (success, height, error) in
            if success {
                if let data = height {
                    self.personalProfile.height = data
                    self.checkDataCount()
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
                    self.checkDataCount()
                }
            } else {
                // error handler
                logger.debug("getWeight error = \(error!.localizedDescription)")
            }
        }
        
        self.getDistance { (distance, error) in
            if error == nil {
                logger.debug("\(distance)")
                self.personalProfile.walkingDistance = distance
                self.checkDataCount()
            } else {
                logger.debug(error?.localizedDescription)
            }
        }
        
        do {
            let age = try self.getAge()
            self.personalProfile.age = age
            checkDataCount()
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
            checkDataCount()
        } catch {
            logger.debug("getSexProblem")
        }
    }
    
    func checkDataCount() {
        profileCount -= 1
        if profileCount == 0 {
            self.delegate?.finishPersonalProfile()
        }
    }
    
    func setDistanceEverydat(_ distance: Double) {
        personalProfile.didCheckDistanceEveryday = true
        personalProfile.distanceEveryday = distance
        Common.ud.set(distance, forKey: Common.SET_WALKING_DISTANCE)
        Common.ud.synchronize()
    }
    
    func getShouldWalkDistance() -> Double {
        return personalProfile.distanceEveryday - personalProfile.walkingDistance
    }
}
