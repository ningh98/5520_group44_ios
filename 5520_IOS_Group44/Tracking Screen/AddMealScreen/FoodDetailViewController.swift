//
//  FoodDetailViewController.swift
//  5520_IOS_Group44
//
//  Created by Ninghui Cai on 11/25/24.
//

import UIKit

class FoodDetailViewController: UIViewController {
    var foodItem:FoodItem?
    
    let detailView = FoodDetailView()
    
    override func loadView() {
        view = detailView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        // Display food details
        if let foodItem = foodItem {
            title = foodItem.food_name
            print("Details for \(foodItem.food_name): \(foodItem.food_description)")
            // Add UI elements to display the details
            detailView.configure(foodName: foodItem.food_name, 
                                 nutrients: foodItem.nutrients,
                                 foodType: foodItem.food_type,
                                 brandName: foodItem.brand_name,
                                 foodURL: foodItem.food_url)
            
            
        }
        
        
    }
    
    

    

}
