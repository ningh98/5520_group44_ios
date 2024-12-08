//
//  CaloryTrackingViewController.swift
//  5520_IOS_Group44
//
//  Created by Bin Yang on 12/4/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class CaloryTrackingViewController: UIViewController {
    
    let caloryTrackingView = CaloryTrackingView()
    var currentUser: FirebaseAuth.User?
    var dailyCalories: Double = 0
    var targetCalories: Int = 1987
    var selectedDate = Date()
    var logId: String?
    var foods: [FoodItem] = []  // Stores the food list
    var meals: [Meal] = []  // Stores the meals list
    
    override func loadView() {
        view = caloryTrackingView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentUser = Auth.auth().currentUser
        title = "Calories Tracking"
        setupUI()
        setupActions()
        setupTableView()
        updateDateLabel()
        updateLogId()
        loadTargetCalories()   // Load target calories for the current date
        fetchDailyCalories()
        fetchMeals()           // Fetch meals data for the current date
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Update current user and refresh data
        currentUser = Auth.auth().currentUser
        updateLogId()
        loadTargetCalories()
        fetchMeals()
        fetchDailyCalories()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        updateProgress()
    }
    
    private func setupActions() {
        caloryTrackingView.addMealButton.addTarget(self, action: #selector(addMealButtonTapped), for: .touchUpInside)
        caloryTrackingView.editTargetButton.addTarget(self, action: #selector(editTargetButtonTapped), for: .touchUpInside)
        caloryTrackingView.leftArrowButton.addTarget(self, action: #selector(leftArrowTapped), for: .touchUpInside)
        caloryTrackingView.rightArrowButton.addTarget(self, action: #selector(rightArrowTapped), for: .touchUpInside)
        
        let dateTapGesture = UITapGestureRecognizer(target: self, action: #selector(dateLabelTapped))
        caloryTrackingView.dateLabel.isUserInteractionEnabled = true
        caloryTrackingView.dateLabel.addGestureRecognizer(dateTapGesture)
    }
    
    private func setupTableView() {
        caloryTrackingView.mealTableView.delegate = self
        caloryTrackingView.mealTableView.dataSource = self
        caloryTrackingView.foodTableView.delegate = self
        caloryTrackingView.foodTableView.dataSource = self
    }
    
    private func updateProgress() {
        caloryTrackingView.currentCalorieLabel.text = "\(Int(dailyCalories))"
        caloryTrackingView.targetCalorieLabel.text = "\(targetCalories)"
        
        let progress = Float(dailyCalories) / Float(targetCalories)
        caloryTrackingView.progressView.setProgress(progress, animated: true)
    }
    
    private func updateDateLabel() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM d"
        caloryTrackingView.dateLabel.text = dateFormatter.string(from: selectedDate)
    }
    
    @objc private func addMealButtonTapped() {
        let addMealVC = AddMealViewController()
        addMealVC.currentUser = currentUser
        addMealVC.saveMealAction = { [weak self] newMeal in
            self?.addMealToFirestore(meal: newMeal)
        }
        navigationController?.pushViewController(addMealVC, animated: true)
    }
    
    private func addMealToFirestore(meal: Meal) {
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
            "fat": meal.fat,
            "created_at": Timestamp(date: selectedDate)
        ]
        
        db.collection("users").document(userId)
            .collection("logs").document(logId)
            .collection("meals").addDocument(data: mealData) { [weak self] error in
                if let error = error {
                    print("Error adding meal: \(error)")
                } else {
                    print("Meal added successfully!")
                    self?.fetchMeals()
                    self?.fetchDailyCalories()
                }
            }
    }
    
    @objc private func editTargetButtonTapped() {
        let alertController = UIAlertController(title: "Daily Budget", message: "calories", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.keyboardType = .numberPad
            textField.placeholder = "Enter target calories"
        }
        let confirmAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            if let textField = alertController.textFields?.first, let text = textField.text, let newTarget = Int(text) {
                self?.targetCalories = newTarget
                self?.caloryTrackingView.targetCalorieLabel.text = "\(newTarget)"
                self?.updateProgress()
                self?.saveTargetCalories(newTarget)
            } else {
                self?.showInvalidInputAlert()
            }
        }
        alertController.addAction(confirmAction)
        present(alertController, animated: true, completion: nil)
    }
    
    private func showInvalidInputAlert() {
        let alert = UIAlertController(title: "Invalid Input", message: "Please enter a valid number.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @objc private func leftArrowTapped() {
        selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
        updateDateLabel()
        updateLogId()
        loadTargetCalories()   // Reload target calories when switching dates
        fetchMeals()
        fetchDailyCalories()
    }
    
    @objc private func rightArrowTapped() {
        selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
        updateDateLabel()
        updateLogId()
        loadTargetCalories()   // Reload target calories when switching dates
        fetchMeals()
        fetchDailyCalories()
    }
    
    @objc private func dateLabelTapped() {
        let datePickerVC = UIViewController()
        datePickerVC.preferredContentSize = CGSize(width: view.frame.width, height: 250)
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.date = selectedDate
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        datePickerVC.view.addSubview(datePicker)
        
        NSLayoutConstraint.activate([
            datePicker.leadingAnchor.constraint(equalTo: datePickerVC.view.leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: datePickerVC.view.trailingAnchor),
            datePicker.topAnchor.constraint(equalTo: datePickerVC.view.topAnchor),
            datePicker.bottomAnchor.constraint(equalTo: datePickerVC.view.bottomAnchor)
        ])
        
        let alertController = UIAlertController(title: "Select Date", message: nil, preferredStyle: .actionSheet)
        alertController.setValue(datePickerVC, forKey: "contentViewController")
        
        let selectAction = UIAlertAction(title: "Select", style: .default) { [weak self] _ in
            self?.selectedDate = datePicker.date
            self?.updateDateLabel()
            self?.updateLogId()
            self?.loadTargetCalories() // Reload target calories when switching dates
            self?.fetchMeals()
            self?.fetchDailyCalories()
        }
        alertController.addAction(selectAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }

    private func updateLogId() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        logId = dateFormatter.string(from: selectedDate)
        print("📅 Generated logId: \(logId ?? "nil") for date: \(selectedDate)")
    }
    
    private func saveTargetCalories(_ target: Int) {
        guard let userId = currentUser?.uid else {
            print("⚠️ Failed to save target: userId is nil")
            return
        }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: startOfDay)
        
        let db = Firestore.firestore()
        let data: [String: Any] = [
            "target_calories": target,
            "date": Timestamp(date: startOfDay)
        ]
        
        db.collection("users").document(userId)
            .collection("calorie_targets").document(dateString)
            .setData(data, merge: true) { error in
                if let error = error {
                    print("❌ Error saving target calories: \(error.localizedDescription)")
                } else {
                    print("✅ Target calories saved successfully")
                }
            }
    }
    
    private func loadTargetCalories() {
        guard let userId = currentUser?.uid else {
            print("⚠️ Failed to load target: userId is nil")
            return
        }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: startOfDay)
        
        let db = Firestore.firestore()
        db.collection("users").document(userId)
            .collection("calorie_targets").document(dateString)
            .getDocument { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("❌ Error loading target calories: \(error.localizedDescription)")
                    return
                }
                
                if let data = snapshot?.data(),
                   let target = data["target_calories"] as? Int {
                    DispatchQueue.main.async {
                        self.targetCalories = target
                        self.caloryTrackingView.targetCalorieLabel.text = "\(target)"
                        self.updateProgress()
                    }
                } else {
                    print("📊 No target calories found for date \(dateString)")
                    // Set default value to 2000 if no target calories are found
                    DispatchQueue.main.async {
                        self.targetCalories = 2000
                        self.caloryTrackingView.targetCalorieLabel.text = "2000"
                        self.updateProgress()
                    }
                }
            }
    }
    
    private func fetchFoods() {
        guard let userId = currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        let startOfDay = Calendar.current.startOfDay(for: selectedDate)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        
        print("🔍 Fetching foods for date: \(selectedDate)")
        print("🔍 LogId: \(logId ?? "nil")")
        
        db.collection("users").document(userId)
            .collection("logs").document(logId ?? "")
            .collection("foods")
            .whereField("time", isGreaterThanOrEqualTo: Timestamp(date: startOfDay))
            .whereField("time", isLessThan: Timestamp(date: endOfDay))
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("❌ Error fetching foods: \(error.localizedDescription)")
                    return
                }
                
                if let foodDocuments = snapshot?.documents {
                    print("📊 Found \(foodDocuments.count) foods")
                    
                    self.foods = foodDocuments.map { doc -> FoodItem in
                        let data = doc.data()
                        print("🍽️ Food: \(data["food_name"] ?? "unnamed"), Calories: \(data["custom_calories"] ?? 0)")
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
                    
                    print("✅ Processed \(self.foods.count) foods")
                    
                    DispatchQueue.main.async {
                        self.caloryTrackingView.foodTableView.reloadData()
                    }
                }
            }
    }
    
    private func fetchDailyCalories() {
        guard let userId = currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        
        db.collection("users").document(userId)
            .collection("logs").document(logId ?? "")
            .collection("meals")
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("❌ Error fetching meals: \(error.localizedDescription)")
                    return
                }
                
                var totalCalories: Double = 0
                let dispatchGroup = DispatchGroup()
                
                if let documents = snapshot?.documents {
                    for mealDoc in documents {
                        dispatchGroup.enter()
                        db.collection("users").document(userId)
                            .collection("logs").document(self.logId ?? "")
                            .collection("meals").document(mealDoc.documentID)
                            .collection("foods")
                            .getDocuments { snapshot, error in
                                defer { dispatchGroup.leave() }
                                
                                if let error = error {
                                    print("❌ Error fetching foods for meal \(mealDoc.documentID): \(error.localizedDescription)")
                                    return
                                }
                                
                                if let foodDocs = snapshot?.documents {
                                    for foodDoc in foodDocs {
                                        let data = foodDoc.data()
                                        if let calories = data["custom_calories"] as? Double {
                                            totalCalories += calories
                                        }
                                    }
                                }
                            }
                    }
                }
                
                dispatchGroup.notify(queue: .main) {
                    self.dailyCalories = totalCalories
                    self.caloryTrackingView.dailyCaloriesLabel.text = "Daily: \(Int(totalCalories))"
                    self.updateProgress()
                }
            }
    }
    
    private func fetchMeals() {
        guard let userId = currentUser?.uid,
              let logId = logId else {
            print("❌ Error: Missing userId or logId")
            self.meals = []
            DispatchQueue.main.async {
                self.caloryTrackingView.mealTableView.reloadData()
            }
            return
        }
        
        print("🔍 Fetching meals for logId: \(logId)")
        
        let db = Firestore.firestore()
        db.collection("users").document(userId)
            .collection("logs").document(logId)
            .collection("meals")
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("❌ Error fetching meals: \(error)")
                    return
                }
                
                if let documents = snapshot?.documents {
                    print("📊 Found \(documents.count) meals")
                    self.meals = documents.map { doc -> Meal in
                        let data = doc.data()
                        let meal = Meal(
                            mealId: doc.documentID,
                            name: data["name"] as? String ?? "Unnamed Meal",
                            calories: data["calories"] as? Double ?? 0,
                            protein: data["protein"] as? Double ?? 0,
                            carbs: data["carbs"] as? Double ?? 0,
                            fat: data["fat"] as? Double ?? 0
                        )
                        print("🍽️ Meal: \(meal.name), Calories: \(meal.calories)")
                        return meal
                    }
                    
                    DispatchQueue.main.async {
                        self.caloryTrackingView.mealTableView.reloadData()
                    }
                }
            }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if tableView == caloryTrackingView.mealTableView && editingStyle == .delete {
            let meal = meals[indexPath.row]
            deleteMeal(meal) { [weak self] success in
                if success {
                    self?.meals.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    self?.fetchDailyCalories()
                }
            }
        }
    }
    
    private func deleteMeal(_ meal: Meal, completion: @escaping (Bool) -> Void) {
        guard let userId = currentUser?.uid,
              let logId = logId,
              let mealId = meal.mealId else {
            print("❌ Error: Missing userId, logId, or mealId")
            completion(false)
            return
        }
        
        let db = Firestore.firestore()
        let mealRef = db.collection("users").document(userId)
            .collection("logs").document(logId)
            .collection("meals").document(mealId)
        
        // Delete all foods under the meal
        mealRef.collection("foods").getDocuments { snapshot, error in
            if let error = error {
                print("❌ Error fetching foods to delete: \(error)")
                completion(false)
                return
            }
            
            let batch = db.batch()
            
            snapshot?.documents.forEach { doc in
                let foodRef = mealRef.collection("foods").document(doc.documentID)
                batch.deleteDocument(foodRef)
            }
            
            batch.deleteDocument(mealRef)
            
            batch.commit { error in
                if let error = error {
                    print("❌ Error deleting meal and its foods: \(error)")
                    completion(false)
                } else {
                    print("✅ Successfully deleted meal and its foods")
                    completion(true)
                }
            }
        }
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension CaloryTrackingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == caloryTrackingView.mealTableView {
            return meals.count
        } else {
            return foods.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if tableView == caloryTrackingView.mealTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MealCell", for: indexPath)
            let meal = meals[indexPath.row]
            cell.textLabel?.text = meal.name
            cell.detailTextLabel?.text = "\(Int(meal.calories)) kcal"
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FoodCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "FoodCell")
            let food = foods[indexPath.row]
            cell.textLabel?.text = food.food_name
            cell.detailTextLabel?.text = "Calories: \(Int(food.custom_calories ?? 0))"
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if tableView == caloryTrackingView.mealTableView {
            let meal = meals[indexPath.row]
            let mealDetailVC = MealDetailViewController()
            mealDetailVC.currentUser = currentUser
            mealDetailVC.logId = logId
            mealDetailVC.selectedMeal = meal
            navigationController?.pushViewController(mealDetailVC, animated: true)
        }
    }
}
