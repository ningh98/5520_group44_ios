//
//  FoodDetailView.swift
//  5520_IOS_Group44
//
//  Created by Ninghui Cai on 11/26/24.
//

import UIKit

class FoodDetailView: UIView {

    var foodNameLabel: UILabel!
    var servingSizeLabel: UILabel!
    var caloriesLabel: UILabel!
    var fatLabel: UILabel!
    var carbsLabel: UILabel!
    var proteinLabel: UILabel!
    var foodTypeLabel: UILabel!
    var foodURLLabel: UILabel!
    var brandNameLabel: UILabel!
    var customServingSizeTextField: UITextField!
    var addButton: UIButton!
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = .white

        // Food Name Label
        foodNameLabel = UILabel()
        foodNameLabel.font = UIFont.boldSystemFont(ofSize: 24)
        foodNameLabel.textColor = .black
        foodNameLabel.numberOfLines = 0
        foodNameLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(foodNameLabel)

        // Nutrient Labels
        servingSizeLabel = createNutrientLabel()
        caloriesLabel = createNutrientLabel()
        fatLabel = createNutrientLabel()
        carbsLabel = createNutrientLabel()
        proteinLabel = createNutrientLabel()
        
        // Additional Labels
        foodTypeLabel = createNutrientLabel()
        foodURLLabel = createNutrientLabel(textColor: .blue) // Blue for clickable links
        brandNameLabel = createNutrientLabel()
        
        // Custom Serving Size
        customServingSizeTextField = UITextField()
        customServingSizeTextField.borderStyle = .roundedRect
        customServingSizeTextField.keyboardType = .decimalPad
        customServingSizeTextField.placeholder = "Custom serving size (same unit as orignial)"
        customServingSizeTextField.translatesAutoresizingMaskIntoConstraints = false
        customServingSizeTextField.addTarget(self, action: #selector(customServingSizeChanged), for: .editingChanged)
        

        // Add Button
        addButton = UIButton(type: .system)
        addButton.setTitle("Add to Meal", for: .normal)
        addButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        addButton.isEnabled = false // Initially disable the button
        addButton.translatesAutoresizingMaskIntoConstraints = false
        
        
        addSubview(servingSizeLabel)
        addSubview(caloriesLabel)
        addSubview(fatLabel)
        addSubview(carbsLabel)
        addSubview(proteinLabel)
        addSubview(foodTypeLabel)
        addSubview(foodURLLabel)
        addSubview(brandNameLabel)
        addSubview(customServingSizeTextField)
        addSubview(addButton)

        // Add constraints
        NSLayoutConstraint.activate([
            foodNameLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            foodNameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            foodNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            servingSizeLabel.topAnchor.constraint(equalTo: foodNameLabel.bottomAnchor, constant: 12),
            servingSizeLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            servingSizeLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            caloriesLabel.topAnchor.constraint(equalTo: servingSizeLabel.bottomAnchor, constant: 20),
            caloriesLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            caloriesLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            fatLabel.topAnchor.constraint(equalTo: caloriesLabel.bottomAnchor, constant: 12),
            fatLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            fatLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            carbsLabel.topAnchor.constraint(equalTo: fatLabel.bottomAnchor, constant: 12),
            carbsLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            carbsLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            proteinLabel.topAnchor.constraint(equalTo: carbsLabel.bottomAnchor, constant: 12),
            proteinLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            proteinLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            foodTypeLabel.topAnchor.constraint(equalTo: proteinLabel.bottomAnchor, constant: 20),
            foodTypeLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            foodTypeLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            brandNameLabel.topAnchor.constraint(equalTo: foodTypeLabel.bottomAnchor, constant: 12),
            brandNameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            brandNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            foodURLLabel.topAnchor.constraint(equalTo: brandNameLabel.bottomAnchor, constant: 12),
            foodURLLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            foodURLLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            customServingSizeTextField.topAnchor.constraint(equalTo: foodURLLabel.bottomAnchor, constant: 20),
            customServingSizeTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            customServingSizeTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            addButton.topAnchor.constraint(equalTo: customServingSizeTextField.bottomAnchor, constant: 20),
            addButton.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
    private func createNutrientLabel(textColor: UIColor = .darkGray) -> UILabel {
       let label = UILabel()
       label.font = UIFont.systemFont(ofSize: 16)
       label.textColor = textColor
       label.translatesAutoresizingMaskIntoConstraints = false
       return label
   }

   func configure(foodName: String,
                  nutrients: (servingSize: String, calories: String, fat: String, carbs: String, protein: String)?,
                  foodType: String,
                  brandName: String?,
                  foodURL: String?) {
       foodNameLabel.text = foodName
       
       originalNutrients = nutrients // Store the nutrients for calculations
       
       if let nutrients = nutrients {
           servingSizeLabel.text = "Serving Size: \(nutrients.servingSize)"
           caloriesLabel.text = "Calories: \(nutrients.calories) kcal"
           fatLabel.text = "Fat: \(nutrients.fat) g"
           carbsLabel.text = "Carbs: \(nutrients.carbs) g"
           proteinLabel.text = "Protein: \(nutrients.protein) g"
       } else {
           servingSizeLabel.text = "Serving Size: Not available"
           caloriesLabel.text = "Nutrient data not available"
           fatLabel.text = ""
           carbsLabel.text = ""
           proteinLabel.text = ""
       }
       
       foodTypeLabel.text = "Type: \(foodType)"
       brandNameLabel.text = brandName != nil ? "Brand: \(brandName!)" : "Brand: Not available"
       foodURLLabel.text = foodURL != nil ? "URL: \(foodURL!)" : "URL: Not available"
   }
    
    private var originalNutrients: (servingSize: String, calories: String, fat: String, carbs: String, protein: String)?

    @objc private func customServingSizeChanged() {
        guard let text = customServingSizeTextField.text,
                  let customSize = Double(text),
                  let nutrients = originalNutrients,
                  let originalServingSize = nutrients.servingSize.extractNumericValue(),
                  let originalCalories = nutrients.calories.extractNumericValue(),
                  let originalFat = nutrients.fat.extractNumericValue(),
                  let originalCarbs = nutrients.carbs.extractNumericValue(),
                  let originalProtein = nutrients.protein.extractNumericValue() else {
            addButton.isEnabled = false
            return
        }
        
        // Calculate the nutrition facts for the custom serving size
        let multiplier = customSize / nutrients.servingSize.extractNumericValue()!
        let customCalories = multiplier * nutrients.calories.extractNumericValue()!
        let customFat = multiplier * nutrients.fat.extractNumericValue()!
        let customCarbs = multiplier * nutrients.carbs.extractNumericValue()!
        let customProtein = multiplier * nutrients.protein.extractNumericValue()!
        
        // Format to two decimal places
        let formattedCalories = String(format: "%.2f", customCalories)
        let formattedFat = String(format: "%.2f", customFat)
        let formattedCarbs = String(format: "%.2f", customCarbs)
        let formattedProtein = String(format: "%.2f", customProtein)

        // Update the labels
            caloriesLabel.text = "Calories: \(formattedCalories) kcal"
            fatLabel.text = "Fat: \(formattedFat) g"
            carbsLabel.text = "Carbs: \(formattedCarbs) g"
            proteinLabel.text = "Protein: \(formattedProtein) g"

        // Enable the button
        addButton.isEnabled = true
    }
    
}
