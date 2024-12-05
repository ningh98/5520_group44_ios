//
//  Log.swift
//  5520_IOS_Group44
//
//  Created by Ninghui Cai on 11/21/24.
//

import Foundation

struct Log: Codable{
    var date: Date
    var comment: String
    var logId: String? // Add the Firestore document ID
    var trackingData: TrackingData?
    var fastingData: FastingData?
    var dailyTotalCalories: Double
    var dailyTotalProtein: Double
    var dailyTotalCarbs: Double
    var dailyTotalFat: Double
    
    init(date: Date, comment: String, logId: String? = nil, trackingData: TrackingData? = nil, fastingData: FastingData? = nil, dailyTotalCalories: Double = 0, dailyTotalProtein: Double = 0, dailyTotalCarbs: Double = 0, dailyTotalFat: Double = 0) {
        self.date = date
        self.comment = comment
        self.logId = logId
        self.trackingData = trackingData
        self.fastingData = fastingData
        self.dailyTotalCalories = dailyTotalCalories
        self.dailyTotalProtein = dailyTotalProtein
        self.dailyTotalCarbs = dailyTotalCarbs
        self.dailyTotalFat = dailyTotalFat
    }
}

struct Meal {
    let mealId: String?
    let name: String
    let calories: Double
    let protein: Double
    let carbs: Double
    let fat: Double
}

// Placeholder structs for TrackingData and FastingData
// Change them if needed

struct TrackingData: Codable {
    var calories: Int
    var protein: Double
    var carbs: Double
    var fats: Double
}


struct FastingData: Codable {
    var startTime: Date
    var endTime: Date
    var duration: TimeInterval {
        return endTime.timeIntervalSince(startTime)
    }
}
