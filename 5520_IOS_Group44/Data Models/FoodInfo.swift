//
//  FoodInfo.swift
//  5520_IOS_Group44
//
//  Created by Ninghui Cai on 11/25/24.
//

import Foundation

// Define a structure for the food items
struct FoodItem: Decodable {
    let food_id: String
    let food_name: String
    let food_description: String
    let food_type: String
    let food_url: String
    let brand_name: String? // Optional, as it may not always be present
    
    var nutrients: (servingSize: String,calories: String, fat: String, carbs: String, protein: String)? {
        let pattern = #"Per\s+([^|]+)\s*-\s*Calories:\s*(\d+\.?\d*)kcal\s*\|\s*Fat:\s*(\d+\.?\d*)g\s*\|\s*Carbs:\s*(\d+\.?\d*)g\s*\|\s*Protein:\s*(\d+\.?\d*)g"#


        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        
        if let match = regex?.firstMatch(in: food_description, range: NSRange(food_description.startIndex..., in: food_description)) {
            let servingSize = extract(from: match, at: 1, in: food_description)
            let calories = extract(from: match, at: 2, in: food_description)
            let fat = extract(from: match, at: 3, in: food_description)
            let carbs = extract(from: match, at: 4, in: food_description)
            let protein = extract(from: match, at: 5, in: food_description)
//            print("Extracted nutrients: ServingSize=\(servingSize), Calories=\(calories), Fat=\(fat), Carbs=\(carbs), Protein=\(protein)")
            return (servingSize, calories, fat, carbs, protein)
        }
//        print("Regex did not match food_description: \(food_description)")
        return nil
    }
    
    private func extract(from match: NSTextCheckingResult, at index: Int, in text: String) -> String {
        guard let range = Range(match.range(at: index), in: text) else { return "" }
        return String(text[range])
    }
}

extension String {
    func extractNumericValue() -> Double? {
        let pattern = #"(\d+(\.\d+)?)"# // Matches integers and decimals
        let regex = try? NSRegularExpression(pattern: pattern)
        if let match = regex?.firstMatch(in: self, range: NSRange(startIndex..., in: self)),
           let range = Range(match.range(at: 1), in: self) {
            return Double(self[range]) // Convert the matched value to Double
        }
        return nil // Return nil if no numeric value is found
    }
}

// Define the response structure
struct FoodResponse: Decodable {
    let foods: Foods
}

struct Foods: Decodable {
    let food: [FoodItem]
    let max_results: String
    let page_number: String
    let total_results: String
}


