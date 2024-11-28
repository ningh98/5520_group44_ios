//
//  AddMealViewController.swift
//  5520_IOS_Group44
//
//  Created by Ninghui Cai on 11/23/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore


class AddMealViewController: UIViewController {
    var currentUser:FirebaseAuth.User?
    
    let addMealScreen = AddMealView()
    
    
    
    //MARK: the array to display the food name...
    var namesForTableView = [String]()
    var foodItems = [FoodItem]() // Store full food item details for navigation to detail view
    
    override func loadView() {
        view = addMealScreen
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = false
        title = "Add To Meal"
                
        //MARK: setting up Table View data source and delegate...
        addMealScreen.tableViewSearchResults.delegate = self
        addMealScreen.tableViewSearchResults.dataSource = self
        
        //MARK: setting up Search Bar delegate...
        addMealScreen.searchBar.delegate = self
        
        
    }
    
    // MARK: Fetch food data from FatSecret API
    func fetchFoodData(searchQuery: String) {
        // Replace with your Firebase function URL
        let urlString = "https://us-central1-apiproxy-iosgroup44project.cloudfunctions.net/fatsecretProxy"
        
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
                    self.addMealScreen.tableViewSearchResults.reloadData()
                }
            } catch {
                print("Error parsing food data: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
    

    

}
