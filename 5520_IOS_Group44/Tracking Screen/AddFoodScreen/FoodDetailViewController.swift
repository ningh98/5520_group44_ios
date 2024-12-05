//
//  FoodDetailViewController.swift
//  5520_IOS_Group44
//
//  Created by Ninghui Cai on 11/25/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class FoodDetailViewController: UIViewController, UITextFieldDelegate {
    var foodItem:FoodItem?
    var currentUser: FirebaseAuth.User?
    var logId: String?
    var mealId: String?
    
    let detailView = FoodDetailView()
    
    override func loadView() {
        view = detailView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        // Display food details
        if let foodItem = foodItem {
            title = foodItem.food_name
            print("Details for \(foodItem.food_name): \(foodItem.food_description)")
            // Add UI elements to display the details
            detailView.configure(foodName: foodItem.food_name,
                                 nutrients: foodItem.nutrients,
                                 foodType: foodItem.food_type,
                                 brandName: foodItem.brand_name,
                                 foodURL: foodItem.food_url)
            
            
        }
        // Set text field delegate
        detailView.customServingSizeTextField.delegate = self
        
        detailView.addButton.isEnabled = false
        
        
        detailView.addButton.addTarget(self, action: #selector(addFoodToMeal), for: .touchUpInside)
        
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Check if the text field will be empty after the change
        let updatedText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string
        detailView.addButton.isEnabled = !updatedText.isEmpty
        return true
    }
    
    @objc private func addFoodToMeal() {
        guard let userId = currentUser?.uid,
              let logId = logId,
              let mealId = mealId,
              let food = foodItem,
              let customServingSize = detailView.customServingSizeTextField.text?.extractNumericValue(),
              let customCalories = detailView.caloriesLabel.text?.extractNumericValue(),
              let customFat = detailView.fatLabel.text?.extractNumericValue(),
              let customCarbs = detailView.carbsLabel.text?.extractNumericValue(),
              let customProtein = detailView.proteinLabel.text?.extractNumericValue() else {
            print("Error: Missing required values or user input.")
            return
        }
        
        let db = Firestore.firestore()
        let foodData: [String: Any] = [
            "food_name": food.food_name,
            "food_description": food.food_description,
            "food_type": food.food_type,
            "food_url": food.food_url,
            "brand_name": food.brand_name ?? "",
            "custom_servingSize": customServingSize,
            "custom_calories": customCalories,
            "custom_fat": customFat,
            "custom_carbs": customCarbs,
            "custom_protein": customProtein
        ]
        
        db.collection("users").document(userId)
            .collection("logs").document(logId)
            .collection("meals").document(mealId)
            .collection("foods").addDocument(data: foodData) { error in
                if let error = error {
                    print("Error adding food to meal: \(error.localizedDescription)")
                } else {
                    print("Food successfully added to meal!")
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
    }

    
    

    

}
