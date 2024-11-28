//
//  TrackingViewController.swift
//  5520_IOS_Group44
//
//  Created by Ninghui Cai on 11/21/24.
//

import UIKit
import FirebaseAuth

class TrackingViewController: UIViewController {
    
    let trackingView = TrackingView()
    
    var trackingTotal = [TrackingData]()  // For daily totals
    var mealTracking = [TrackingData]()  // For individual meals
    
    
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
        
        //MARK: tapping the floating add meal button...
        trackingView.floatingButtonAddMeal.addTarget(self, action: #selector(addMealButtonTapped), for: .touchUpInside)
        
        trackingView.tableViewMeal.delegate = self
        trackingView.tableViewMeal.dataSource = self
        
        // Example data
        trackingTotal = [
            TrackingData(calories: 2000, protein: 150.0, carbs: 250.0, fats: 70.0) // Daily total
        ]
        
        mealTracking = [
            TrackingData(calories: 500, protein: 40.0, carbs: 50.0, fats: 10.0), // Meal 1
            TrackingData(calories: 700, protein: 60.0, carbs: 80.0, fats: 15.0), // Meal 2
            TrackingData(calories: 300, protein: 20.0, carbs: 30.0, fats: 5.0)   // Meal 3
        ]
        
        trackingView.tableViewTotalTracking.reloadData()
        trackingView.tableViewMeal.reloadData()
    }
    
    @objc func addMealButtonTapped(){
        let addMealController = AddMealViewController()
//        addMealController.currentUser = self.currentUser
        navigationController?.pushViewController(addMealController, animated: true)
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

