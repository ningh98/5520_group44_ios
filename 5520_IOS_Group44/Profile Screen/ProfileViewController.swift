//
//  ProfileViewController.swift
//  5520_IOS_Group44
//
//  Created by Ninghui Cai on 11/21/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ProfileViewController: UIViewController {
    // MARK: - Properties
    private let profileView = ProfileView()
    private let db = Firestore.firestore()
    private var currentUser: FirebaseAuth.User?
    
    // MARK: - Lifecycle
    override func loadView() {
        view = profileView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupActions()
        currentUser = Auth.auth().currentUser
        loadUserData()
    }
    
    // MARK: - Setup
    private func setupNavigation() {
        title = "Profile"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupActions() {
        // Add tap gestures to all items
        let items: [(view: ProfileItemView, selector: Selector)] = [
            (profileView.userNameItem, #selector(editUserName)),
            (profileView.currentWeightItem, #selector(editCurrentWeight)),
            (profileView.goalWeightItem, #selector(editGoalWeight)),
            (profileView.heightItem, #selector(editHeight)),
            (profileView.sexItem, #selector(editSex)),
            (profileView.birthDateItem, #selector(editBirthDate)),
            (profileView.activityLevelItem, #selector(editActivityLevel))
        ]
        
        items.forEach { item, selector in
            let tap = UITapGestureRecognizer(target: self, action: selector)
            item.isUserInteractionEnabled = true
            item.addGestureRecognizer(tap)
        }
    }
    
    // MARK: - Firebase Data Management
    private func loadUserData() {
        guard let userId = currentUser?.uid else { return }
        
        db.collection("users").document(userId).getDocument { [weak self] snapshot, error in
            if let error = error {
                print("Error loading user data: \(error)")
                return
            }
            
            guard let data = snapshot?.data() else {
                print("No user data found")
                return
            }
            
            DispatchQueue.main.async {
                // Update UI with user data
                self?.profileView.userNameItem.valueLabel.text = data["userName"] as? String ?? "Not set"
                self?.profileView.currentWeightItem.valueLabel.text = "\(data["currentWeight"] as? Int ?? 0) lbs"
                self?.profileView.goalWeightItem.valueLabel.text = "\(data["goalWeight"] as? Int ?? 0) lbs"
                self?.profileView.heightItem.valueLabel.text = data["height"] as? String ?? "Not set"
                self?.profileView.sexItem.valueLabel.text = data["sex"] as? String ?? "Not set"
                self?.profileView.birthDateItem.valueLabel.text = data["birthDate"] as? String ?? "Not set"
                self?.profileView.activityLevelItem.valueLabel.text = data["activityLevel"] as? String ?? "Not set"
            }
        }
    }
    
    private func saveUserData() {
        guard let userId = currentUser?.uid else { return }
        
        // Extract values from UI
        let userData: [String: Any] = [
            "userName": profileView.userNameItem.valueLabel.text ?? "",
            "currentWeight": Int(profileView.currentWeightItem.valueLabel.text?.components(separatedBy: " ").first ?? "0") ?? 0,
            "goalWeight": Int(profileView.goalWeightItem.valueLabel.text?.components(separatedBy: " ").first ?? "0") ?? 0,
            "height": profileView.heightItem.valueLabel.text ?? "",
            "sex": profileView.sexItem.valueLabel.text ?? "",
            "birthDate": profileView.birthDateItem.valueLabel.text ?? "",
            "activityLevel": profileView.activityLevelItem.valueLabel.text ?? "",
            "lastUpdated": FieldValue.serverTimestamp()
        ]
        
        db.collection("users").document(userId).setData(userData, merge: true) { error in
            if let error = error {
                print("Error saving user data: \(error)")
            } else {
                print("User data saved successfully")
            }
        }
    }
    
    // MARK: - Actions
    @objc private func editUserName() {
        let currentValue = profileView.userNameItem.valueLabel.text ?? ""
        showTextFieldAlert(title: "Edit Name", message: "Enter your name", currentValue: currentValue) { [weak self] newValue in
            self?.profileView.userNameItem.valueLabel.text = newValue
            self?.saveUserData()
        }
    }
    
    @objc private func editCurrentWeight() {
        showNumberPickerAlert(title: "Current Weight", unit: "lbs", range: 80...400) { [weak self] value in
            self?.profileView.currentWeightItem.valueLabel.text = "\(value) lbs"
            self?.saveUserData()
        }
    }
    
    @objc private func editGoalWeight() {
        showNumberPickerAlert(title: "Goal Weight", unit: "lbs", range: 80...400) { [weak self] value in
            self?.profileView.goalWeightItem.valueLabel.text = "\(value) lbs"
            self?.saveUserData()
        }
    }
    
    @objc private func editHeight() {
        showHeightPicker()
    }
    
    @objc private func editSex() {
        showSexPicker()
    }
    
    @objc private func editBirthDate() {
        showDatePicker()
    }
    
    @objc private func editActivityLevel() {
        let alert = UIAlertController(title: "Activity Level", message: nil, preferredStyle: .actionSheet)
        
        ["Sedentary", "Lightly active", "Moderately active", "Very active", "Extra active"].forEach { level in
            let action = UIAlertAction(title: level, style: .default) { [weak self] _ in
                self?.profileView.activityLevelItem.valueLabel.text = level
                self?.saveUserData()
            }
            alert.addAction(action)
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    // MARK: - Helper Methods
    private func showTextFieldAlert(title: String, message: String, currentValue: String, completion: @escaping (String) -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = currentValue
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default) { _ in
            if let text = alert.textFields?.first?.text, !text.isEmpty {
                completion(text)
            }
        })
        
        present(alert, animated: true)
    }
    
    private func showNumberPickerAlert(title: String, unit: String, range: ClosedRange<Int>, completion: @escaping (Int) -> Void) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        let pickerView = UIPickerView()
        pickerView.tag = 1 // Tag for weight picker
        pickerView.delegate = self
        pickerView.dataSource = self
        
        // Set initial selection
        if let currentValue = Int(profileView.currentWeightItem.valueLabel.text?.components(separatedBy: " ").first ?? "0") {
            let row = max(0, min(currentValue - 80, 320))
            pickerView.selectRow(row, inComponent: 0, animated: false)
        }
        
        let contentVC = UIViewController()
        contentVC.view = pickerView
        alert.setValue(contentVC, forKey: "contentViewController")
        
        alert.addAction(UIAlertAction(title: "Done", style: .default) { _ in
            let selectedRow = pickerView.selectedRow(inComponent: 0)
            completion(selectedRow + 80)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alert.view.heightAnchor.constraint(equalToConstant: 300).isActive = true
        present(alert, animated: true)
    }
    
    private func showHeightPicker() {
        let alert = UIAlertController(title: "Height", message: nil, preferredStyle: .actionSheet)
        let pickerView = UIPickerView()
        pickerView.tag = 0 // Tag for height picker
        pickerView.delegate = self
        pickerView.dataSource = self
        
        let contentVC = UIViewController()
        contentVC.view = pickerView
        alert.setValue(contentVC, forKey: "contentViewController")
        
        alert.addAction(UIAlertAction(title: "Done", style: .default) { [weak self] _ in
            let feet = pickerView.selectedRow(inComponent: 0) + 4
            let inches = pickerView.selectedRow(inComponent: 1)
            self?.profileView.heightItem.valueLabel.text = "\(feet) ft \(inches) in"
            self?.saveUserData()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alert.view.heightAnchor.constraint(equalToConstant: 300).isActive = true
        present(alert, animated: true)
    }
    
    private func showSexPicker() {
        let alert = UIAlertController(title: "Select Biological Sex", message: nil, preferredStyle: .actionSheet)
        
        ["Male", "Female"].forEach { sex in
            let action = UIAlertAction(title: sex, style: .default) { [weak self] _ in
                self?.profileView.sexItem.valueLabel.text = sex
                self?.saveUserData()
            }
            alert.addAction(action)
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    private func showDatePicker() {
        let alert = UIAlertController(title: "Date of Birth", message: nil, preferredStyle: .actionSheet)
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        
        let contentVC = UIViewController()
        contentVC.view = datePicker
        alert.setValue(contentVC, forKey: "contentViewController")
        
        alert.addAction(UIAlertAction(title: "Done", style: .default) { [weak self] _ in
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            self?.profileView.birthDateItem.valueLabel.text = formatter.string(from: datePicker.date)
            self?.saveUserData()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alert.view.heightAnchor.constraint(equalToConstant: 300).isActive = true
        present(alert, animated: true)
    }
}

// MARK: - UIPickerViewDelegate & DataSource
extension ProfileViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerView.tag == 1 { // Weight picker
            return 1
        }
        return 2 // Height picker (feet and inches)
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1 { // Weight picker
            return 321 // 80-400 lbs
        }
        return component == 0 ? 4 : 12 // 4-7 feet, 0-11 inches
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1 { // Weight picker
            return "\(row + 80) lbs"
        }
        if component == 0 {
            return "\(row + 4) ft"
        } else {
            return "\(row) in"
        }
    }
}
