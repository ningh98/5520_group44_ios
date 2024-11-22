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
    var trackingData: TrackingData?
    var fastingData: FastingData?
    
    init(date: Date, comment: String, trackingData: TrackingData? = nil, fastingData: FastingData? = nil) {
        self.date = date
        self.comment = comment
        self.trackingData = trackingData
        self.fastingData = fastingData
    }
}


// Placeholder structs for TrackingData and FastingData
// Change them if needed

struct TrackingData: Codable {
    var calories: Int
    var protein: Double
    var carbs: Double
    var fats: Double
    var targetCalories: Int
    var targetProtein: Double
    var targetCarbs: Double
    var targetFats: Double
    
    init(calories: Int = 0, protein: Double = 0, carbs: Double = 0, fats: Double = 0,
         targetCalories: Int = 2000, targetProtein: Double = 150, targetCarbs: Double = 250, targetFats: Double = 70) {
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fats = fats
        self.targetCalories = targetCalories
        self.targetProtein = targetProtein
        self.targetCarbs = targetCarbs
        self.targetFats = targetFats
    }
}


struct FastingData: Codable {
    var startTime: Date
    var endTime: Date
    var duration: TimeInterval {
        return endTime.timeIntervalSince(startTime)
    }
}
