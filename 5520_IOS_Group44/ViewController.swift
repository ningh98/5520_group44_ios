//
//  ViewController.swift
//  5520_IOS_Group44
//
//  Created by Ninghui Cai on 11/21/24.
//

import UIKit
import FirebaseAuth
import Network

class ViewController: UITabBarController, UITabBarControllerDelegate {
    
    // Define the index of the profile tab, determined after the view is initialized
    var profileTabIndex: Int? = nil
    private let monitor = NWPathMonitor()
    private var isConnected = true

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Set the delegate to intercept tab selection
        self.delegate = self
        
        //MARK: Setting up the Home tab bar...
        let tabHome = UINavigationController(rootViewController: MainScreenViewController())
        let tabHomeBarItem = UITabBarItem(
            title: "Home",
            image: UIImage(systemName: "house")?.withRenderingMode(.alwaysTemplate),
            selectedImage: UIImage(systemName: "house.fill")
        )
        tabHome.tabBarItem = tabHomeBarItem
        tabHome.title = "Home"
        
        //MARK: Setting up the Tracking tab bar...
        let tabTracking = UINavigationController(rootViewController: TrackingViewController())
        let tabTrackingBarItem = UITabBarItem(
            title: "Tracking",
            image: UIImage(systemName: "carrot")?.withRenderingMode(.alwaysOriginal),
            selectedImage: UIImage(systemName: "carrot.fill")
        )
        tabTracking.tabBarItem = tabTrackingBarItem
        tabTracking.title = "Tracking"
        
        //MARK: Setting up the Calorie Tracking tab bar...
        let caloryTrackingVC = CaloryTrackingViewController()
        caloryTrackingVC.currentUser = Auth.auth().currentUser
        let tabCaloryTracking = UINavigationController(rootViewController: caloryTrackingVC)
        let tabCaloryTrackingBarItem = UITabBarItem(
            title: "Calories",
            image: UIImage(systemName: "flame")?.withRenderingMode(.alwaysTemplate),
            selectedImage: UIImage(systemName: "flame.fill")
        )
        tabCaloryTracking.tabBarItem = tabCaloryTrackingBarItem
        
        //MARK: Setting up the Fasting tab bar...
        let fastingVC = FastingViewController()
        fastingVC.currentUser = Auth.auth().currentUser
        let tabFasting = UINavigationController(rootViewController: fastingVC)
        let tabFastingBarItem = UITabBarItem(
            title: "Fasting",
            image: UIImage(systemName: "clock")?.withRenderingMode(.alwaysTemplate),
            selectedImage: UIImage(systemName: "clock.fill")
        )
        tabFasting.tabBarItem = tabFastingBarItem
        tabFasting.title = "Fasting"
        
        //MARK: Setting up the Profile tab bar...
        let tabProfile = UINavigationController(rootViewController: ProfileViewController())
        let tabProfileBarItem = UITabBarItem(
            title: "Profile",
            image: UIImage(systemName: "person")?.withRenderingMode(.alwaysTemplate),
            selectedImage: UIImage(systemName: "person.fill")
        )
        tabProfile.tabBarItem = tabProfileBarItem
        tabProfile.title = "Profile"

        //MARK: Setting up the Chatbot tab bar...
        let tabChatbot = UINavigationController(rootViewController: ChatbotViewController())
        let tabChatbotBarItem = UITabBarItem(
            title: "Chatbot",
            image: UIImage(systemName: "bubble.left")?.withRenderingMode(.alwaysTemplate),
            selectedImage: UIImage(systemName: "bubble.left.fill")
        )
        tabChatbot.tabBarItem = tabChatbotBarItem
        tabChatbot.title = "Chatbot"
        
        //MARK: Setting up this view controller as the Tab Bar Controller...
        // Current viewControllers order: [tabCaloryTracking, tabFasting, tabChatbot, tabProfile]
        // Index: CaloryTracking=0, Fasting=1, Chatbot=2, Profile=3
        self.viewControllers = [tabCaloryTracking, tabFasting, tabChatbot, tabProfile]
        
        // Profile is the last tab, Index=3
        profileTabIndex = 3
        
        // If the user is not logged in, default to selecting the Profile tab
        if Auth.auth().currentUser == nil, let profileIndex = profileTabIndex {
            self.selectedIndex = profileIndex
        }
    }
    
    // Intercept tab selection
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        // Find the index of the tab to be selected
        guard let viewControllers = tabBarController.viewControllers,
              let index = viewControllers.firstIndex(of: viewController) else {
            return true
        }

        // If the user is not logged in
        if Auth.auth().currentUser == nil {
            // Prevent switching to tabs other than the Profile tab
            if let profileIndex = profileTabIndex, index != profileIndex {
                // Optionally, show an alert asking the user to log in
                let alert = UIAlertController(title: "Not Signed In", message: "Please sign in to continue.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
                return false
            }
        }
        
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupNetworkMonitoring()
        
        Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            // Update FastingViewController's currentUser when the authentication state changes
            // Note: viewControllers order is [tabCaloryTracking, tabFasting, tabChatbot, tabProfile]
            // fasting is at index=1
            if let fastingVC = self?.viewControllers?[1] as? UINavigationController,
               let rootVC = fastingVC.viewControllers.first as? FastingViewController {
                rootVC.currentUser = user
                if user != nil {
                    rootVC.loadLastFastingSession()
                    rootVC.loadFastingHistory()
                }
            }
        }
    }
    
    private func setupNetworkMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
                if !(self?.isConnected ?? true) {
                    let alert = UIAlertController(
                        title: "No Internet Connection",
                        message: "Please check your internet connection and try again.",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(alert, animated: true)
                }
            }
        }
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
    }
    
    deinit {
        monitor.cancel()  
    }
}
