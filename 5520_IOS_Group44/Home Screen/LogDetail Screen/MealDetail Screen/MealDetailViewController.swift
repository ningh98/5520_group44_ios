//
//  MealDetailViewController.swift
//  5520_IOS_Group44
//
//  Created by Ninghui Cai on 12/4/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class MealDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foods.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FoodCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "FoodCell")
        let food = foods[indexPath.row]
        
        // Configure the cell with food details
        cell.textLabel?.text = food.food_name
        cell.detailTextLabel?.text = "Calories: \(food.nutrients?.calories ?? "0") kcal"
        
        return cell
    }
    // MARK: Swipe-to-Delete food

   func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
       if editingStyle == .delete {
           let foodToDelete = foods[indexPath.row]
           deleteFoodFromFirestore(food: foodToDelete) { [weak self] success in
               guard let self = self else { return }
               if success {
                   self.foods.remove(at: indexPath.row) // Remove from local array
                   self.updateMealTotals() // Update totals immediately
                   DispatchQueue.main.async {
                       tableView.deleteRows(at: [indexPath], with: .automatic) // Refresh the table view
                   }
               } else {
                   print("Failed to delete food from Firestore.")
               }
           }
       }
   }
    
  
    
    

   private func deleteFoodFromFirestore(food: FoodItem, completion: @escaping (Bool) -> Void) {
       guard let userId = currentUser?.uid, let logId = logId, let mealId = selectedMeal?.mealId else {
           completion(false)
           return
       }
       
       let db = Firestore.firestore()
       db.collection("users").document(userId)
           .collection("logs").document(logId)
           .collection("meals").document(mealId)
           .collection("foods").document(food.food_id).delete { error in
               if let error = error {
                   print("Error deleting food: \(error.localizedDescription)")
                   completion(false)
               } else {
                   completion(true)
               }
           }
   }
    
    var currentUser: FirebaseAuth.User?
    var logId: String?
    var selectedMeal: Meal?
    var foods = [FoodItem]() // Store the foods for this meal

    let mealDetailView = MealDetailView() // Custom view for this controller

    override func loadView() {
        view = mealDetailView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = selectedMeal?.name ?? "Meal Details"
        
       
        mealDetailView.foodsTableView.delegate = self
        mealDetailView.foodsTableView.dataSource = self
        mealDetailView.addFoodButton.addTarget(self, action: #selector(navigateToAddFoodScreen), for: .touchUpInside)

        fetchFoods()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchFoods() // Fetch the latest data whenever the view appears
    }

    private func fetchFoods() {
        guard let userId = currentUser?.uid, let logId = logId, let mealId = selectedMeal?.mealId else { return }

        let db = Firestore.firestore()
        db.collection("users").document(userId)
            .collection("logs").document(logId)
            .collection("meals").document(mealId)
            .collection("foods").getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching foods: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                self.foods = documents.map { doc -> FoodItem in
                    let data = doc.data()
                    return FoodItem(
                        food_id: doc.documentID,
                        food_name: data["food_name"] as? String ?? "Unnamed Food",
                        food_description: data["food_description"] as? String ?? "",
                        food_type: data["food_type"] as? String ?? "",
                        food_url: data["food_url"] as? String ?? "",
                        brand_name: data["brand_name"] as? String,
                        custom_calories: data["custom_calories"] as? Double ?? 0,
                        custom_fat: data["custom_fat"] as? Double ?? 0,
                        custom_carbs: data["custom_carbs"] as? Double ?? 0,
                        custom_protein: data["custom_protein"] as? Double ?? 0,
                        custom_servingSize: data["custom_servingSize"] as? Double ?? 0
                    )
                }

                self.updateMealTotals() // Calculate totals
                DispatchQueue.main.async {
                    self.mealDetailView.foodsTableView.reloadData()
                }
            }
    }
    
    private func updateMealTotals() {
        var totalCalories: Double = 0
        var totalCarbs: Double = 0
        var totalFats: Double = 0
        var totalProtein: Double = 0

        for food in foods {
            totalCalories += food.custom_calories ?? 0
            totalCarbs += food.custom_carbs ?? 0
            totalFats += food.custom_fat ?? 0
            totalProtein += food.custom_protein ?? 0
        }

        // Update the UI to display these totals
        DispatchQueue.main.async { // Ensure UI updates happen on the main thread
            self.mealDetailView.totalCaloriesLabel.text = "Total Calories: \(String(format: "%.2f", totalCalories))"
            self.mealDetailView.totalCarbsLabel.text = "Carbs: \(String(format: "%.2f", totalCarbs)) g"
            self.mealDetailView.totalFatsLabel.text = "Fats: \(String(format: "%.2f", totalFats)) g"
            self.mealDetailView.totalProteinLabel.text = "Protein: \(String(format: "%.2f", totalProtein)) g"
        }
    }



    @objc private func navigateToAddFoodScreen() {
        let addFoodVC = AddFoodViewController()
        addFoodVC.currentUser = currentUser
        addFoodVC.logId = logId
        addFoodVC.selectedMeal = selectedMeal
        
        // Set a completion handler to refresh data after adding food
        addFoodVC.completionHandler = { [weak self] in
            self?.fetchFoods()
        }
        navigationController?.pushViewController(addFoodVC, animated: true)
    }
}

