//
//  ViewController.swift
//  5520_IOS_Group44
//
//  Created by Ninghui Cai on 11/21/24.
//

import UIKit
import FirebaseAuth

class ViewController: UITabBarController, UITabBarControllerDelegate {
    
    // 定义 profileTab 的索引，当视图初始化后确定
    var profileTabIndex: Int? = nil

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
        
        //MARK: setting up Calory Tracking tab bar...
        let caloryTrackingVC = CaloryTrackingViewController()
        caloryTrackingVC.currentUser = Auth.auth().currentUser
        let tabCaloryTracking = UINavigationController(rootViewController: caloryTrackingVC)
        let tabCaloryTrackingBarItem = UITabBarItem(
            title: "Calories",
            image: UIImage(systemName: "flame")?.withRenderingMode(.alwaysTemplate),
            selectedImage: UIImage(systemName: "flame.fill")
        )
        tabCaloryTracking.tabBarItem = tabCaloryTrackingBarItem
        
        //MARK: setting up Fasting tab bar...
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
        
        //MARK: setting up Profile tab bar...
        let tabProfile = UINavigationController(rootViewController: ProfileViewController())
        let tabProfileBarItem = UITabBarItem(
            title: "Profile",
            image: UIImage(systemName: "person")?.withRenderingMode(.alwaysTemplate),
            selectedImage: UIImage(systemName: "person.fill")
        )
        tabProfile.tabBarItem = tabProfileBarItem
        tabProfile.title = "Profile"

        //MARK: setting up Chatbot tab bar...
        let tabChatbot = UINavigationController(rootViewController: ChatbotViewController())
        let tabChatbotBarItem = UITabBarItem(
            title: "Chatbot",
            image: UIImage(systemName: "bubble.left")?.withRenderingMode(.alwaysTemplate),
            selectedImage: UIImage(systemName: "bubble.left.fill")
        )
        tabChatbot.tabBarItem = tabChatbotBarItem
        tabChatbot.title = "Chatbot"
        
        //MARK: setting up this view controller as the Tab Bar Controller...
        // 当前viewControllers顺序为 [tabCaloryTracking, tabFasting, tabChatbot, tabProfile]
        // Index: CaloryTracking=0, Fasting=1, Chatbot=2, Profile=3
        self.viewControllers = [tabCaloryTracking, tabFasting, tabChatbot, tabProfile]
        
        // Profile是最后一个Index=3
        profileTabIndex = 3
        
        // 如果用户未登录，默认选中Profile tab
        if Auth.auth().currentUser == nil, let profileIndex = profileTabIndex {
            self.selectedIndex = profileIndex
        }
    }
    
    // Intercept tab selection
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        // 找出即将选中的 tab 的 index
        guard let viewControllers = tabBarController.viewControllers,
              let index = viewControllers.firstIndex(of: viewController) else {
            return true
        }

        // 如果用户未登录
        if Auth.auth().currentUser == nil {
            // 如果点击的不是Profile tab，那么就不允许切换，从而用户只能待在Profile tab
            if let profileIndex = profileTabIndex, index != profileIndex {
                // 可以在这里弹出提示要求登录
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
        
        Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            // Update FastingViewController's currentUser when auth state changes
            // 注意，这里viewControllers是 [tabCaloryTracking, tabFasting, tabChatbot, tabProfile]
            // fasting 在 index=1
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
}
