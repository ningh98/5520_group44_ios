//
//  LogDetailViewController.swift
//  5520_IOS_Group44
//
//  Created by Ninghui Cai on 12/2/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class LogDetailViewController: UIViewController {
    
    var log: Log? // Log passed from MainScreenViewController
    var logId: String?
    var currentUser: FirebaseAuth.User? // Current user
    var trackingTotal = [TrackingData]()  // For daily totals
    var mealTracking = [Meal]()  // For individual meals
    
    let trackingView = TrackingView()
    
    override func loadView() {
        view = trackingView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Log Details"

        // Table View setup
        trackingView.tableViewTotalTracking.delegate = self
        trackingView.tableViewTotalTracking.dataSource = self
        trackingView.tableViewMeal.delegate = self
        trackingView.tableViewMeal.dataSource = self

        // Floating button action
        trackingView.floatingButtonAddMeal.addTarget(self, action: #selector(addMealTapped), for: .touchUpInside)
        
        if let logId = logId {
            fetchMeals(for: logId)
        }
       
       
        trackingView.tableViewTotalTracking.reloadData()
        trackingView.tableViewMeal.reloadData()

        if let logId = logId {
            fetchMealsAndAggregateNutrients(for: logId)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Fetch meals and aggregate nutrients whenever the view appears
        if let logId = logId {
            fetchMeals(for: logId)
            fetchMealsAndAggregateNutrients(for: logId)
        }
    }
    

    
    
    func fetchMealsAndAggregateNutrients(for logId: String) {
        guard let userId = currentUser?.uid else { return }

        let db = Firestore.firestore()
        db.collection("users").document(userId)
            .collection("logs").document(logId)
            .collection("meals").getDocuments { [weak self] snapshot, error in
                guard let self = self, let mealDocuments = snapshot?.documents else {
                    print("Error fetching meals: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }

                var totalCalories: Double = 0
                var totalProtein: Double = 0
                var totalCarbs: Double = 0
                var totalFat: Double = 0

                let group = DispatchGroup()

                mealDocuments.forEach { mealDoc in
                    group.enter()
                    db.collection("users").document(userId)
                        .collection("logs").document(logId)
                        .collection("meals").document(mealDoc.documentID)
                        .collection("foods").getDocuments { foodSnapshot, foodError in
                            if let foodDocuments = foodSnapshot?.documents {
                                foodDocuments.forEach { foodDoc in
                                    let foodData = foodDoc.data()
                                    totalCalories += foodData["custom_calories"] as? Double ?? 0
                                    totalProtein += foodData["custom_protein"] as? Double ?? 0
                                    totalCarbs += foodData["custom_carbs"] as? Double ?? 0
                                    totalFat += foodData["custom_fat"] as? Double ?? 0
                                }
                            } else {
                                print("Error fetching foods: \(foodError?.localizedDescription ?? "Unknown error")")
                            }
                            group.leave()
                        }
                }

                group.notify(queue: .main) {
                    self.updateNutritionalData(calories: totalCalories, protein: totalProtein, carbs: totalCarbs, fat: totalFat)
                }
            }
    }
    
    func updateNutritionalData(calories: Double, protein: Double, carbs: Double, fat: Double) {
        self.trackingTotal = [
            TrackingData(
                calories: Int(calories), // Calories can remain as an integer if needed
                protein: Double(String(format: "%.2f", protein)) ?? protein,
                carbs: Double(String(format: "%.2f", carbs)) ?? carbs,
                fats: Double(String(format: "%.2f", fat)) ?? fat
            )
        ]
        DispatchQueue.main.async {
            self.trackingView.tableViewTotalTracking.reloadData()
        }
    }
    func updateMealNutritionalData(meal: Meal) {
        guard let userId = currentUser?.uid, let logId = logId, let mealId = meal.mealId else { return }
        
        let db = Firestore.firestore()
        let mealDocRef = db.collection("users").document(userId)
                            .collection("logs").document(logId)
                            .collection("meals").document(mealId)
        
        mealDocRef.collection("foods").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching foods to update meal data: \(error.localizedDescription)")
                return
            }
            
            var totalCalories: Double = 0
            var totalProtein: Double = 0
            var totalCarbs: Double = 0
            var totalFat: Double = 0
            
            // Aggregate nutritional data
            snapshot?.documents.forEach { doc in
                let data = doc.data()
                totalCalories += data["custom_calories"] as? Double ?? 0
                totalProtein += data["custom_protein"] as? Double ?? 0
                totalCarbs += data["custom_carbs"] as? Double ?? 0
                totalFat += data["custom_fat"] as? Double ?? 0
            }
            
            // Update the meal document
            mealDocRef.updateData([
                "calories": totalCalories,
                "protein": totalProtein,
                "carbs": totalCarbs,
                "fat": totalFat
            ]) { updateError in
                if let updateError = updateError {
                    print("Error updating meal nutritional data: \(updateError.localizedDescription)")
                }
            }
        }
    }

    
    func fetchMeals(for logId: String) {
        guard let userId = currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        db.collection("users").document(userId).collection("logs").document(logId).collection("meals").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents, error == nil else {
                print("Error fetching meals: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            self.mealTracking = documents.map { doc in
                let data = doc.data()
                return Meal(
                    mealId: doc.documentID,
                    name: data["name"] as? String ?? "Unnamed Meal",
                    calories: data["calories"] as? Double ?? 0,
                    protein: data["protein"] as? Double ?? 0,
                    carbs: data["carbs"] as? Double ?? 0,
                    fat: data["fat"] as? Double ?? 0
                )
            }
            
            DispatchQueue.main.async {
                self.trackingView.tableViewMeal.reloadData()
            }
        }
    }

    

    @objc private func addMealTapped() {
        print("Floating button tapped!") // Debug statement
        guard let logId = logId else {
            print("Error: Log ID is nil")
            return
        }
        let addMealController = AddMealViewController()
        addMealController.currentUser = currentUser
        addMealController.saveMealAction = { [weak self] newMeal in
                guard let self = self else { return }
                print("Callback triggered with meal: \(newMeal)")
                self.addMealToFirestore(meal: newMeal)
            }
        navigationController?.pushViewController(addMealController, animated: true)
        // Navigate to AddMealViewController
        
    }
    
    func addMealToFirestore(meal: Meal) {
        guard let userId = currentUser?.uid, let logId = logId else {
            print("Error: Missing userId or logId")
            return
        }
        
        let db = Firestore.firestore()
        let mealData: [String: Any] = [
            "name": meal.name,
            "calories": meal.calories,
            "protein": meal.protein,
            "carbs": meal.carbs,
            "fat": meal.fat
        ]
        print("Attempting to add meal for userId: \(userId), logId: \(logId)")
        print("Meal data being written: \(mealData)")
        
        db.collection("users").document(userId).collection("logs").document(logId).collection("meals").addDocument(data: mealData) { error in
            if let error = error {
                print("Error adding meal: \(error)")
            } else {
                print("Meal added successfully!")
                self.fetchMealsAndAggregateNutrients(for: logId)
            }
        }
    }

}
