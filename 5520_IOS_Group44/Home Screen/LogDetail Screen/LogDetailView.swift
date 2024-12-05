//
//  LogDetailView.swift
//  5520_IOS_Group44
//
//  Created by Ninghui Cai on 12/2/24.
//

import UIKit

class LogDetailView: UIView {

    var logTitleLabel: UILabel!
    var tableViewTotalTracking: UITableView!
    var tableViewMeals: UITableView!
    var addMealButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        
        // Log Title Label
        logTitleLabel = UILabel()
        logTitleLabel.font = .boldSystemFont(ofSize: 24)
        logTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(logTitleLabel)
        
        tableViewTotalTracking = UITableView()
        tableViewTotalTracking.register(TotalTrackingTableViewCell.self, forCellReuseIdentifier: Configs.tableViewTotalTrackingID)
        tableViewTotalTracking.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(tableViewTotalTracking)
        
        // Table View for Meals
        tableViewMeals = UITableView()
        tableViewMeals.register(UITableViewCell.self, forCellReuseIdentifier: Configs.tableViewMealID)
        tableViewMeals.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tableViewMeals)
        
        // Add Meal Button
        addMealButton = UIButton(type: .system)
        addMealButton.setTitle("Add Meal", for: .normal)
        addMealButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        addMealButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(addMealButton)
        
        // Constraints
        NSLayoutConstraint.activate([
            logTitleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            logTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            logTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            tableViewMeals.topAnchor.constraint(equalTo: logTitleLabel.bottomAnchor, constant: 16),
            tableViewMeals.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableViewMeals.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableViewMeals.bottomAnchor.constraint(equalTo: addMealButton.topAnchor, constant: -16),
            
            addMealButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addMealButton.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
