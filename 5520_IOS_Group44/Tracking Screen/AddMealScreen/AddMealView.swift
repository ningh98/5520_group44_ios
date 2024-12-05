//
//  AddMealView.swift
//  5520_IOS_Group44
//
//  Created by Ninghui Cai on 12/3/24.
//

import UIKit

class AddMealView: UIView {

    var mealNameTextField: UITextField!
    var saveButton: UIButton!
    var cancelButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .white
        
        // Comment TextField
        mealNameTextField = UITextField()
        mealNameTextField.borderStyle = .roundedRect
        mealNameTextField.placeholder = "Enter Meal Name"
        mealNameTextField.translatesAutoresizingMaskIntoConstraints = false
        addSubview(mealNameTextField)
        
        // Save Button
        saveButton = UIButton(type: .system)
        saveButton.setTitle("Save", for: .normal)
        saveButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(saveButton)
        
        // Cancel Button
        cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(cancelButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Text Field Constraints
            mealNameTextField.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            mealNameTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            mealNameTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            // Save Button Constraints
            saveButton.topAnchor.constraint(equalTo: mealNameTextField.bottomAnchor, constant: 20),
            saveButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            // Cancel Button Constraints
            cancelButton.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 10),
            cancelButton.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }

}
