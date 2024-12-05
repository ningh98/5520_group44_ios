//
//  TrackingViewController.swift
//  5520_IOS_Group44
//
//  Created by Ninghui Cai on 11/21/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class TrackingViewController: UIViewController {
    
    let trackingView = TrackingView()
    
    var currentUser: FirebaseAuth.User? // Current user
    var logId: String? // Log ID for the current log
    var trackingTotal = [TrackingData]()  // For daily totals
    var mealTracking = [Meal]()  // For individual meals
    
    
    override func loadView(){
        view = trackingView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Nutrition Tracking"
        
        //MARK: Make the titles look large...
        navigationController?.navigationBar.prefersLargeTitles = true
        
        //MARK: patching table view delegate and data source...
        trackingView.tableViewTotalTracking.delegate = self
        trackingView.tableViewTotalTracking.dataSource = self
        trackingView.tableViewMeal.delegate = self
        trackingView.tableViewMeal.dataSource = self
        
        //MARK: tapping the floating add meal button...
        trackingView.floatingButtonAddMeal.addTarget(self, action: #selector(addMealButtonTapped), for: .touchUpInside)
        
        // Fetch the latest log and meals
        fetchLatestLogAndMeals()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Fetch latest log and meals on view appear
        fetchLatestLogAndMeals()
    }
    
    @objc func addMealButtonTapped(){
        guard let logId = logId else {
            print("Error: No log ID available")
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
    }
    
    func fetchLatestLogAndMeals() {
        guard let userId = currentUser?.uid else { return }
        let db = Firestore.firestore()
        
        // Query logs collection, order by date descending, and get the most recent one
        db.collection("users").document(userId).collection("logs")
            .order(by: "date", descending: true)
            .limit(to: 1)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("Error fetching latest log: \(error.localizedDescription)")
                    return
                }
                
                guard let self = self, let document = snapshot?.documents.first else {
                    print("No logs found")
                    self?.logId = nil
                    self?.trackingTotal = [] // Clear tracking data
                    DispatchQueue.main.async {
                        self?.trackingView.tableViewTotalTracking.reloadData()
                    }
                    return
                }
                
                
                
                self.logId = document.documentID // Store the log ID
                let data = document.data()
                
                print("Fetched log data: \(data)") // Check log details
                
                let totalCalories = data["dailyTotalCalories"] as? Double ?? 0
                let totalProtein = data["dailyTotalProtein"] as? Double ?? 0
                let totalCarbs = data["dailyTotalCarbs"] as? Double ?? 0
                let totalFats = data["dailyTotalFat"] as? Double ?? 0
                
                self.trackingTotal = [TrackingData(calories: Int(totalCalories), protein: totalProtein, carbs: totalCarbs, fats: totalFats)]
                DispatchQueue.main.async {
                    self.trackingView.tableViewTotalTracking.reloadData()
                    self.trackingView.tableViewMeal.reloadData()
                }
                
                // Fetch meals for this log
                self.fetchMeals(for: self.logId!)
            }
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
                self.fetchMeals(for: logId)
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




    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

