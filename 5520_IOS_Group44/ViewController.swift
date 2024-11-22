//
//  ViewController.swift
//  5520_IOS_Group44
//
//  Created by Ninghui Cai on 11/21/24.
//

import UIKit
import FirebaseAuth

class ViewController: UITabBarController, UITabBarControllerDelegate {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Set the delegate to intercept tab selection
        self.delegate = self
        
        //MARK: setting up Home tab bar...
        let tabHome = UINavigationController(rootViewController: MainScreenViewController())
        let tabHomeBarItem = UITabBarItem(
            title: "Home",
            image: UIImage(systemName: "house")?.withRenderingMode(.alwaysTemplate),
            selectedImage: UIImage(systemName: "house.fill")
        )
        tabHome.tabBarItem = tabHomeBarItem
        tabHome.title = "Home"
        
        //MARK: setting up Tracking tab bar...
        let tabTracking = UINavigationController(rootViewController: TrackingViewController())
        let tabTrackingBarItem = UITabBarItem(
            title: "Tracking",
            image: UIImage(systemName: "carrot")?.withRenderingMode(.alwaysOriginal),
            selectedImage: UIImage(systemName: "carrot.fill")
        )
        tabTracking.tabBarItem = tabTrackingBarItem
        tabTracking.title = "Tracking"
        
        //MARK: setting up Fasting tab bar...
        let tabFasting = UINavigationController(rootViewController: FastingViewController())
        let tabFastingBarItem = UITabBarItem(
            title: "Fasting",
            image: UIImage(systemName: "clock")?.withRenderingMode(.alwaysTemplate),
            selectedImage: UIImage(systemName: "clock.fill")
        )
        tabFasting.tabBarItem = tabFastingBarItem
        tabFasting.title = "Fasting"
        
        //MARK: setting up Profile tab bar...
        let tabProfile = UINavigationController(rootViewController: ProfileViewController())
        let tabProfileBarItem = UITabBarItem(
            title: "Profile",
            image: UIImage(systemName: "person")?.withRenderingMode(.alwaysOriginal),
            selectedImage: UIImage(systemName: "person.fill")
        )
        tabProfile.tabBarItem = tabProfileBarItem
        tabProfile.title = "Profile"
        
        //MARK: setting up this view controller as the Tab Bar Controller...
        self.viewControllers = [tabHome, tabTracking, tabFasting, tabProfile]
        
        
        
    }
    
    // Intercept tab selection
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        // Check if the user is signed in
        if Auth.auth().currentUser == nil {
            // If not signed in, show the sign-in popup
            if let homeVC = viewControllers?.first(where: { $0 is UINavigationController })?.children.first as? MainScreenViewController {
                homeVC.onSignInBarButtonTapped()
            }
            return false
        }
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "CalFasting"
        
    }
}

