//
//  TrackingView.swift
//  5520_IOS_Group44
//
//  Created by Ninghui Cai on 11/21/24.
//

import UIKit

class TrackingView: UIView {

    var tableViewTotalTracking: UITableView!
    var tableViewMeal: UITableView!
    var floatingButtonAddMeal: UIButton!
    
    
    override init(frame: CGRect){
        super.init(frame: frame)
        self.backgroundColor = .white
        
        setupTableViewTotalTracking()
        setupTableViewMeal()
        setupFloatingButtonAddMeal()

        
        initConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupTableViewTotalTracking(){
        tableViewTotalTracking = UITableView()
        tableViewTotalTracking.register(TotalTrackingTableViewCell.self, forCellReuseIdentifier: Configs.tableViewTotalTrackingID)
        tableViewTotalTracking.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(tableViewTotalTracking)
    }
    
    func setupTableViewMeal(){
        tableViewMeal = UITableView()
        tableViewMeal.register(MealTableViewCell.self, forCellReuseIdentifier: Configs.tableViewMealID)
        tableViewMeal.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(tableViewMeal)
    }
    
    func setupFloatingButtonAddMeal(){
        floatingButtonAddMeal = UIButton(type: .system)
        floatingButtonAddMeal.setTitle("", for: .normal)
        floatingButtonAddMeal.setImage(UIImage(systemName: "plus.circle.dashed")?.withRenderingMode(.alwaysOriginal), for: .normal)
        floatingButtonAddMeal.contentHorizontalAlignment = .fill
        floatingButtonAddMeal.contentVerticalAlignment = .fill
        floatingButtonAddMeal.imageView?.contentMode = .scaleAspectFit
        floatingButtonAddMeal.layer.cornerRadius = 16
        floatingButtonAddMeal.imageView?.layer.shadowOffset = .zero
        floatingButtonAddMeal.imageView?.layer.shadowRadius = 0.8
        floatingButtonAddMeal.imageView?.layer.shadowOpacity = 0.7
        floatingButtonAddMeal.imageView?.clipsToBounds = true
        floatingButtonAddMeal.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(floatingButtonAddMeal)
    }
    
    
    func initConstraints(){
        NSLayoutConstraint.activate([
            tableViewTotalTracking.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 32),
            tableViewTotalTracking.widthAnchor.constraint(equalToConstant: 200),
            tableViewTotalTracking.heightAnchor.constraint(equalToConstant: 100),
            tableViewTotalTracking.centerXAnchor.constraint(equalTo: self.safeAreaLayoutGuide.centerXAnchor),
            
            
            
            tableViewMeal.topAnchor.constraint(equalTo: tableViewTotalTracking.bottomAnchor, constant: 8),
            tableViewMeal.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            tableViewMeal.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            tableViewMeal.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -16),
            
            floatingButtonAddMeal.widthAnchor.constraint(equalToConstant: 48),
            floatingButtonAddMeal.heightAnchor.constraint(equalToConstant: 48),
            floatingButtonAddMeal.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            floatingButtonAddMeal.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -16),
        ])
    }

}
