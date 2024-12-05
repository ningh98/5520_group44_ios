//
//  AddMealViewController.swift
//  5520_IOS_Group44
//
//  Created by Ninghui Cai on 12/3/24.
//

import UIKit
import FirebaseAuth

class AddMealViewController: UIViewController {
    
    var currentUser: FirebaseAuth.User?
    var saveMealAction: ((Meal) -> Void)? // Callback for saving the meal

    let addMealView = AddMealView()


    override func loadView() {
        view = addMealView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupActions()
        
    }
    
    private func setupActions() {
        // Assign button actions
        addMealView.saveButton.addTarget(self, action: #selector(saveMeal), for: .touchUpInside)
        addMealView.cancelButton.addTarget(self, action: #selector(cancelMeal), for: .touchUpInside)
    }

    @objc private func saveMeal() {
        guard let mealName = addMealView.mealNameTextField.text, !mealName.isEmpty else { return }
        let newMeal = Meal(mealId: nil, name: mealName, calories: 0, protein: 0, carbs: 0, fat: 0)
        saveMealAction?(newMeal) // Call the callback to save the meal
        print("Saving meal: \(newMeal)")
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func cancelMeal() {
        dismiss(animated: true, completion: nil)
    }

}
