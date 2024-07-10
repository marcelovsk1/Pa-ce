//
//  HealthKit.swift
//  PaceApp
//
//  Created by Marcelo Amaral Alves on 2024-07-07.
//

import Foundation
import HealthKit

let healthStore = HKHealthStore()

func requestHealthKitAuthorization() {
    let readTypes: Set<HKObjectType> = [HKObjectType.workoutType()]
    let writeTypes: Set<HKSampleType> = [HKSampleType.workoutType()]

    healthStore.requestAuthorization(toShare: writeTypes, read: readTypes) { (success, error) in
        if !success {
            print("HealthKit Authorization Failed: \(error?.localizedDescription ?? "Unknown error")")
        }
    }
}
