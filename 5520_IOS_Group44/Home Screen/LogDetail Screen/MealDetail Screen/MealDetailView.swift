//
//  MealDetailView.swift
//  5520_IOS_Group44
//
//  Created by Ninghui Cai on 12/4/24.
//

import UIKit

class MealDetailView: UIView {
    var foodsTableView: UITableView!
    var addFoodButton: UIButton!
    var totalCaloriesLabel: UILabel!
    var totalCarbsLabel: UILabel!
    var totalFatsLabel: UILabel!
    var totalProteinLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        backgroundColor = .white
        // Add Total Labels
        totalCaloriesLabel = createNutrientLabel()
        totalCarbsLabel = createNutrientLabel()
        totalFatsLabel = createNutrientLabel()
        totalProteinLabel = createNutrientLabel()
        
        addSubview(totalCaloriesLabel)
        addSubview(totalCarbsLabel)
        addSubview(totalFatsLabel)
        addSubview(totalProteinLabel)

        // Table View
        foodsTableView = UITableView()
        foodsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "FoodCell")
        foodsTableView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(foodsTableView)

        // Add Food Button
        addFoodButton = UIButton(type: .system)
        addFoodButton.setTitle("Add Food", for: .normal)
        addFoodButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        addFoodButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(addFoodButton)

        // Constraints
        NSLayoutConstraint.activate([
            totalCaloriesLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            totalCaloriesLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),

            totalCarbsLabel.topAnchor.constraint(equalTo: totalCaloriesLabel.bottomAnchor, constant: 8),
            totalCarbsLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),

            totalFatsLabel.topAnchor.constraint(equalTo: totalCarbsLabel.bottomAnchor, constant: 8),
            totalFatsLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),

            totalProteinLabel.topAnchor.constraint(equalTo: totalFatsLabel.bottomAnchor, constant: 8),
            totalProteinLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),

            foodsTableView.topAnchor.constraint(equalTo: totalProteinLabel.bottomAnchor, constant: 16),
            foodsTableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            foodsTableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            foodsTableView.bottomAnchor.constraint(equalTo: addFoodButton.topAnchor, constant: -16),

            addFoodButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addFoodButton.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
    
    private func createNutrientLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
}

