//
//  AddFoodView.swift
//  5520_IOS_Group44
//
//  Created by Ninghui Cai on 11/23/24.
//

import UIKit

class AddFoodView: UIView {
    var MealNameLabel: UILabel!
    var searchBar: UISearchBar!
    var tableViewSearchResults: UITableView!
    var tableViewAddedFoods: UITableView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        
        // Text Field Meal name:
        MealNameLabel = UILabel()
        MealNameLabel.text = "Meal #"
        MealNameLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(MealNameLabel)
                
        //MARK: Search Bar...
        searchBar = UISearchBar()
        searchBar.placeholder = "Search Foods.."
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(searchBar)
        
        //MARK: Table view search results...
        tableViewSearchResults = UITableView()
        tableViewSearchResults.register(SearchTableViewCell.self, forCellReuseIdentifier: Configs.searchTableViewID)
        tableViewSearchResults.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(tableViewSearchResults)
        
        
        
        //MARK: constraints...
        NSLayoutConstraint.activate([
            MealNameLabel.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            MealNameLabel.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            MealNameLabel.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            searchBar.topAnchor.constraint(equalTo: MealNameLabel.bottomAnchor, constant: 8),
            searchBar.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            tableViewSearchResults.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            tableViewSearchResults.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor),
            tableViewSearchResults.widthAnchor.constraint(equalTo: self.safeAreaLayoutGuide.widthAnchor),
            tableViewSearchResults.widthAnchor.constraint(equalTo: self.safeAreaLayoutGuide.widthAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
    


