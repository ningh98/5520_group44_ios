//
//  TrackingTableManager.swift
//  5520_IOS_Group44
//
//  Created by Ninghui Cai on 12/2/24.
//

import Foundation
import UIKit
import FirebaseFirestore
import FirebaseAuth

extension LogDetailViewController: UITableViewDelegate, UITableViewDataSource{
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
            cell.labelMealNumber.text = "Meal: \(meal.name)"
//            cell.labelCalories.text = "Calories: \(meal.calories)"
//            cell.labelProtein.text = "Protein: \(meal.protein)"
//            cell.labelCarbs.text = "Carbs: \(meal.carbs)"
//            cell.labelFat.text = "Fats: \(meal.fat)"
            return cell
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == trackingView.tableViewMeal {
            let selectedMeal = mealTracking[indexPath.row] // Get the selected meal
            navigateToAddFoodScreen(for: selectedMeal)
        }
    }
    
    // MARK: Swipe-to-Delete meal
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let mealToDelete = mealTracking[indexPath.row]
            deleteMealFromFirestore(meal: mealToDelete) { [weak self] success in
                guard let self = self else { return }
                if success {
                    self.mealTracking.remove(at: indexPath.row) // Remove from local array
                    DispatchQueue.main.async {
                        tableView.deleteRows(at: [indexPath], with: .automatic) // Refresh the table view
                        self.updateMealNutritionalData(meal: mealToDelete) // Update the totals
                    }
                } else {
                    print("Failed to delete meal from Firestore.")
                }
            }
        }
    }
    
    // Method to delete meal from Firestore
    private func deleteMealFromFirestore(meal: Meal, completion: @escaping (Bool) -> Void) {
        guard let userId = currentUser?.uid, let logId = logId, let mealId = meal.mealId else {
            completion(false)
            return
        }

        let db = Firestore.firestore()
        let mealDocRef = db.collection("users").document(userId)
                            .collection("logs").document(logId)
                            .collection("meals").document(mealId)
        
        // Retrieve all food documents in the meal's "foods" sub-collection
        mealDocRef.collection("foods").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching foods for deletion: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            // Start a batch operation
            let batch = db.batch()
            
            // Delete each food document
            snapshot?.documents.forEach { batch.deleteDocument($0.reference) }
            
            // Delete the meal document itself
            batch.deleteDocument(mealDocRef)
            
            // Commit the batch
            batch.commit { batchError in
                if let batchError = batchError {
                    print("Error deleting meal and its sub-collections: \(batchError.localizedDescription)")
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
    }

    private func navigateToAddFoodScreen(for meal: Meal) {
        let mealDetailVC = MealDetailViewController()
        mealDetailVC.currentUser = currentUser
        mealDetailVC.logId = logId
        mealDetailVC.selectedMeal = meal
        navigationController?.pushViewController(mealDetailVC, animated: true)
    }
}

