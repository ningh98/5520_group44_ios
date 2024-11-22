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
}


struct FastingData: Codable {
    var startTime: Date
    var endTime: Date
    var duration: TimeInterval {
        return endTime.timeIntervalSince(startTime)
    }
}
