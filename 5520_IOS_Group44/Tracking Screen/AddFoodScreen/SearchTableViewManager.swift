//
//  SearchTableViewManager.swift
//  5520_IOS_Group44
//
//  Created by Ninghui Cai on 11/23/24.
//

import Foundation
import UIKit


//MARK: adopting Table View protocols...
extension AddFoodViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return namesForTableView.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: Configs.searchTableViewID, for: indexPath) as! SearchTableViewCell
        let foodItem = foodItems[indexPath.row]
        
        cell.labelTitle.text = foodItem.food_name
        
        // Set the snippet of the description (e.g., first 50 characters)
        let description = foodItem.food_description
        cell.labelDescription.text = description.isEmpty ? "No description available." : String(description.prefix(50)) + "..."
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Get the selected food item
        let selectedFood = foodItems[indexPath.row]
        
        // Navigate to the detail view
        let detailVC = FoodDetailViewController()
        detailVC.foodItem = selectedFood
        detailVC.currentUser = currentUser
        detailVC.logId = logId
        detailVC.mealId = selectedMeal?.mealId // Pass the meal ID
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
}

//MARK: adopting the search bar protocol...
extension AddFoodViewController: UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
                    namesForTableView = [] // Clear the table view
                    addFoodScreen.tableViewSearchResults.reloadData()
        } else {
            fetchFoodData(searchQuery: searchText)
        }
    }
}


