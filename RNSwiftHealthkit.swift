//
//  RNSwiftHealthkit.swift
//  <your-project-name>
//
//  Created by Chris McLellan on 29/06/16.
//  Healthkit code from https://www.raywenderlich.com/86336/ios-8-healthkit-swift-getting-started
//

import Foundation

import HealthKit

@objc(RNSwiftHealthKit)
class RNSwiftHealthKit: NSObject {

  var bridge: RCTBridge!  // this is synthesized
  let healthKitStore:HKHealthStore = HKHealthStore() // an instance of the healthkit store

  @objc func typesSetFromDictionary (types: NSDictionary) -> Set <HKObjectType> {

    var typesSet = Set<HKObjectType>()

    if (types["characteristic"] != nil) {
      let typeCharacteristics = types["characteristic"] as! NSArray;

      for characteristic in typeCharacteristics {
        let characteristicIdentifier = HKObjectType.characteristicTypeForIdentifier(characteristic as! String);
        typesSet.insert(characteristicIdentifier!);
      }
    }

    if (types["quantity"] != nil) {
      let typeQuantities = types["quantity"] as! NSArray;

      for quantity in typeQuantities {
        let quantityIdentifier = HKObjectType.quantityTypeForIdentifier(quantity as! String);
        typesSet.insert(quantityIdentifier!);
      }
    }

    if (types["category"] != nil) {
      let typeCategories = types["category"] as! NSArray;

      for category in typeCategories {
        let categoryIdentifier = HKObjectType.categoryTypeForIdentifier(category as! String);
        typesSet.insert(categoryIdentifier!);
      }
    }

    if (types["workout"] != nil) {
      let workoutIdentifier = HKObjectType.workoutType();
      typesSet.insert(workoutIdentifier);
    }

    return typesSet;

  }

  @objc func authorizeHealthKit (typesToWrite: NSDictionary, typesToRead: NSDictionary) -> Void {

    // 1. Set the types you want to write to HK Store using typesSetFromDictionary
    let typesToWriteSet:Set = typesSetFromDictionary(typesToWrite);

    // 2. Set the types you want to read from HK Store using typesSetFromDictionary
    let typesToReadSet:Set = typesSetFromDictionary(typesToRead);

    // 3. If the store is not available (for instance, iPad) return
    if !HKHealthStore.isHealthDataAvailable()
    {
      return;
    }

    // 4. Request HealthKit authorization
    healthKitStore.requestAuthorizationToShareTypes(typesToWriteSet as? Set<HKSampleType>, readTypes: typesToReadSet) { (success, error) -> Void in}

  }


  func readCharacteristics(callback: (NSObject) -> ()) -> Void
  {
     var error:NSError?
     var age:Int!
     var biologicalSex: HKBiologicalSexObject?
     var bloodType: HKBloodTypeObject?

      // Read age and DOB
      do {
        let birthDay = try healthKitStore.dateOfBirth()
        let today = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let differenceComponents = NSCalendar.currentCalendar().components(NSCalendarUnit.Year, fromDate: birthDay, toDate: today, options: NSCalendarOptions(rawValue: 0))
        age = differenceComponents.year
      } catch let error as NSError {
        print(error.localizedDescription)
      }

      // Read biological sex - (will be added to return statement once enum problem solved)
      do {
        biologicalSex = try healthKitStore.biologicalSex();
      } catch let error as NSError {
        print(error.localizedDescription)
      }

      var biologicalSexDefined = biologicalSexLiteral(biologicalSex?.biologicalSex);

      // Read blood type - (will be added to return statement once enum problem solved)
      do {
        bloodType = try healthKitStore.bloodType()
        print(bloodType);
      } catch let error as NSError {
        print(error.localizedDescription)
      }

      var bloodTypeDefined = bloodTypeLiteral(bloodType?.bloodType);

      let ret =  [
        "age": age,
        "sex": biologicalSexDefined,
        "bloodType": bloodTypeDefined
      ]

      callback([ret])
  }

  func biologicalSexLiteral(biologicalSex:HKBiologicalSex?)->String
  {
    var biologicalSexText = "Unknown";

    if  biologicalSex != nil {

      switch( biologicalSex! )
      {
      case .Female:
        biologicalSexText = "Female"
      case .Male:
        biologicalSexText = "Male"
      default:
        break;
      }

    }
    return biologicalSexText;
  }

  func bloodTypeLiteral(bloodType:HKBloodType?)->String
  {

    var bloodTypeText = "Unknown";

    if bloodType != nil {

      switch( bloodType! ) {
      case .APositive:
        bloodTypeText = "A+"
      case .ANegative:
        bloodTypeText = "A-"
      case .BPositive:
        bloodTypeText = "B+"
      case .BNegative:
        bloodTypeText = "B-"
      case .ABPositive:
        bloodTypeText = "AB+"
      case .ABNegative:
        bloodTypeText = "AB-"
      case .OPositive:
        bloodTypeText = "O+"
      case .ONegative:
        bloodTypeText = "O-"
      default:
        break;
      }

    }
    return bloodTypeText;
  }

  func readMostRecentSample(sampleType:HKSampleType , completion: ((HKSample!, NSError!) -> Void)!)
    {
      // 1. Build the Predicate
      let past = NSDate.distantPast() as! NSDate
      let now  = NSDate()
      let mostRecentPredicate = HKQuery.predicateForSamplesWithStartDate(past, endDate:now, options: .None)

      // 2. Build the sort descriptor to return the samples in descending order
      let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: false)

      // 3. we want to limit the number of samples returned by the query to just 1 (the most recent)
      let limit = 1

      // 4. Build samples query
      let sampleQuery = HKSampleQuery(sampleType: sampleType, predicate: mostRecentPredicate, limit: limit, sortDescriptors: [sortDescriptor])
        { (sampleQuery, results, error ) -> Void in

          if let queryError = error {
            completion(nil,error)
            return;
          }

          // Get the first sample
          let mostRecentSample = results!.first as? HKQuantitySample

          // Execute the completion closure
          if completion != nil {
            completion(mostRecentSample,nil)
          }
      }
      // 5. Execute the Query
      self.healthKitStore.executeQuery(sampleQuery)
    }

    func readWeight(callback: (NSObject) -> ()) -> Void
    {
      // 1. Construct an HKSampleType for weight
      let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass)

      // 2. Call the method to read the most recent weight sample
      readMostRecentSample(sampleType!, completion: { (mostRecentWeight, error) -> Void in

        if( error != nil )
        {
          print("Error reading weight from HealthKit Store: \(error.localizedDescription)")
          return;
        }

        var weightLocalizedString = "Unknown";
        let weight = mostRecentWeight as? HKQuantitySample;

        if let kilograms = weight?.quantity.doubleValueForUnit(HKUnit.gramUnitWithMetricPrefix(.Kilo)) {

        let weightFormatter = NSMassFormatter()
          weightFormatter.forPersonMassUse = true;
          weightLocalizedString = weightFormatter.stringFromKilograms(kilograms)
        }

        let ret =  [
          "weight": weightLocalizedString
        ]

        callback([ret])

      });

    }

    func readHeight(callback: (NSObject) -> ()) -> Void
    {
      // 1. Construct an HKSampleType for weight
      let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight)

      // 2. Call the method to read the most recent weight sample
      readMostRecentSample(sampleType!, completion: { (mostRecentHeight, error) -> Void in

        if( error != nil )
        {
          print("Error reading height from HealthKit Store: \(error.localizedDescription)")
          return;
        }

        var heightLocalizedString = "Unknown";
        let height = mostRecentHeight as? HKQuantitySample;

        if let meters = height?.quantity.doubleValueForUnit(HKUnit.meterUnit()) {
          let heightFormatter = NSLengthFormatter()
          heightFormatter.forPersonHeightUse = true;
          heightLocalizedString = heightFormatter.stringFromMeters(meters);
        }

        let ret =  [
          "height": heightLocalizedString
        ]

        callback([ret])

      });

    }


}
