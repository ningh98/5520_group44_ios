//
//  AddLogView.swift
//  5520_IOS_Group44
//
//  Created by Ninghui Cai on 12/2/24.
//

import UIKit

class AddLogView: UIView {

    var datePicker: UIDatePicker!
    var commentTextField: UITextField!
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
        
        // Date Picker
        datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        addSubview(datePicker)
        
        // Comment TextField
        commentTextField = UITextField()
        commentTextField.borderStyle = .roundedRect
        commentTextField.placeholder = "Enter a comment (optional)"
        commentTextField.translatesAutoresizingMaskIntoConstraints = false
        addSubview(commentTextField)
        
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
            // Date Picker Constraints
            datePicker.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            datePicker.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            datePicker.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            // Comment TextField Constraints
            commentTextField.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 20),
            commentTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            commentTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            // Save Button Constraints
            saveButton.topAnchor.constraint(equalTo: commentTextField.bottomAnchor, constant: 20),
            saveButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            // Cancel Button Constraints
            cancelButton.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 10),
            cancelButton.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }

}
