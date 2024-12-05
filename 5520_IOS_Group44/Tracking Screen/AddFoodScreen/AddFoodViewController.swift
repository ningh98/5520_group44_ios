//
//  AddFoodViewController.swift
//  5520_IOS_Group44
//
//  Created by Ninghui Cai on 11/23/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore


class AddFoodViewController: UIViewController {
    var currentUser:FirebaseAuth.User?
    
    var logId: String?
    var selectedMeal: Meal? // Property to store the selected meal
    
    let addFoodScreen = AddFoodView()
    
    var completionHandler:(() -> Void)?
    
    
    
    //MARK: the array to display the food name...
    var namesForTableView = [String]()
    var foodItems = [FoodItem]() // Store full food item details for navigation to detail view
    var addedFoods = [FoodItem]() // Foods added to the database
    
    override func loadView() {
        view = addFoodScreen
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = false
        title = "Add To Meal"
        
        // Use the selectedMeal details for initialization
        if let meal = selectedMeal {
           print("Selected meal: \(meal.name)")
           // Update UI elements with the selected meal details, if needed
        }
                
        //MARK: setting up Table View data source and delegate...
        addFoodScreen.tableViewSearchResults.delegate = self
        addFoodScreen.tableViewSearchResults.dataSource = self
        //MARK: setting up Search Bar delegate...
        addFoodScreen.searchBar.delegate = self
        
        // Fetch added foods
//        fetchAddedFoods()
        
    }
    
    @objc private func goBackAfterAddingFood() {
        // Call the completion handler before popping the view controller
        completionHandler?()
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: Fetch Added Foods
        func fetchAddedFoods() {
        guard let userId = currentUser?.uid, let logId = logId, let mealId = selectedMeal?.mealId else {
            print("Error: Missing userId, logId, or mealId")
            return
        }
        
        let db = Firestore.firestore()
        db.collection("users").document(userId)
            .collection("logs").document(logId)
            .collection("meals").document(mealId)
            .collection("foods").getDocuments { [weak self] snapshot, error in
                guard let self = self, let documents = snapshot?.documents else {
                    print("Error fetching added foods: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                self.addedFoods = documents.map { doc in
                    let data = doc.data()
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
                        custom_servingSize: data["custom_servingSize"] as? Double ?? 1
                    )
                }
                DispatchQueue.main.async {
                    self.addFoodScreen.tableViewAddedFoods.reloadData()
                }
            }
    }
    // MARK: Fetch food data from FatSecret API
    func fetchFoodData(searchQuery: String) {
        // Replace with your Firebase function URL
        let urlString = "http://34.237.160.49:3000"
        
        var components = URLComponents(string: urlString)!
        components.queryItems = [
            URLQueryItem(name: "method", value: "foods.search"),
            URLQueryItem(name: "search_expression", value: searchQuery),
            URLQueryItem(name: "format", value: "json")
        ]
        
        guard let url = components.url else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            if let error = error {
                print("Error fetching food data: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data received from API")
                return
            }
            
            // Log raw data
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw JSON Response: \(jsonString)")
            }
            
            do {
                // Parse the response
                let decoder = JSONDecoder()
                let foodResponse = try decoder.decode(FoodResponse.self, from: data)
                
                DispatchQueue.main.async {
                    self.foodItems = foodResponse.foods.food // Store full items for detail navigation
                    self.namesForTableView = self.foodItems.map { $0.food_name }
                    self.addFoodScreen.tableViewSearchResults.reloadData()
                }
            } catch {
                print("Error parsing food data: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
    

    

}
