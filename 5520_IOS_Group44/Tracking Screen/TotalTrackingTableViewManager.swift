//
//  TotalTrackingTableViewManager.swift
//  5520_IOS_Group44
//
//  Created by Ninghui Cai on 11/21/24.
//

import Foundation
import UIKit

extension TrackingViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == trackingView.tableViewTotalTracking {
            return trackingTotal.count // Only one row
        } else if tableView == trackingView.tableViewMeal {
            return mealTracking.count // One row per meal
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == trackingView.tableViewTotalTracking {
            let cell = tableView.dequeueReusableCell(withIdentifier: Configs.tableViewTotalTrackingID, for: indexPath) as! TotalTrackingTableViewCell
            let total = trackingTotal[indexPath.row]
            cell.labelCalories.text = "Daily Calories: \(total.calories)"
            cell.labelProtein.text = "Daily Protein:\(total.protein)"
            cell.labelCarbs.text = "Daily Carbs:\(total.carbs)"
            cell.labelFat.text = "Daily Fats:\(total.fats)"
            return cell
        } else if tableView == trackingView.tableViewMeal {
            let cell = tableView.dequeueReusableCell(withIdentifier: Configs.tableViewMealID, for: indexPath) as! MealTableViewCell
            let meal = mealTracking[indexPath.row]
            cell.labelMealNumber.text = meal.name.isEmpty ? "Unnamed Meal" : meal.name
//            cell.labelCalories.text = "Calories: \(meal.calories)"
//            cell.labelProtein.text = "Protein: \(meal.protein)"
//            cell.labelCarbs.text = "Carbs: \(meal.carbs)"
//            cell.labelFat.text = "Fats: \(meal.fat)"
            return cell
        }
        return UITableViewCell()
    }
}
