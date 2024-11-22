//
//  MainScreenViewController.swift
//  5520_IOS_Group44
//
//  Created by Ninghui Cai on 11/21/24.
//

import UIKit
import FirebaseAuth

class MainScreenViewController: UIViewController {

    let mainScreenView = MainScreenView()
    
    let childProgressView = ProgressSpinnerViewController()
    
    var logsList = [Log]()
    
    var handleAuth: AuthStateDidChangeListenerHandle?
    var currentUser:FirebaseAuth.User?
    
    override func loadView(){
        view = mainScreenView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //MARK: handling if the Authentication state is changed (sign in, sign out, register)...
        handleAuth = Auth.auth().addStateDidChangeListener{ auth, user in
            if user == nil{
                //MARK: not signed in...
                self.currentUser = nil
                self.mainScreenView.labelText.text = "Please sign in to see the logbook!"
                
                //MARK: Reset tableView...
                self.logsList.removeAll()
                self.mainScreenView.tableViewLogs.reloadData()
                //MARK: Sign in bar button...
                self.setupRightBarButton(isLoggedin: false)
                
            }else{
                //MARK: the user is signed in...
                self.currentUser = user
                self.mainScreenView.labelText.text = "Welcome \(user?.displayName ?? "Anonymous")!"
                
                //MARK: Logout bar button...
                self.setupRightBarButton(isLoggedin: true)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Home"
        
        //MARK: patching table view delegate and data source...
        mainScreenView.tableViewLogs.delegate = self
        mainScreenView.tableViewLogs.dataSource = self
        
        //MARK: removing the separator line...
        mainScreenView.tableViewLogs.separatorStyle = .none
        
        //MARK: Make the titles look large...
        navigationController?.navigationBar.prefersLargeTitles = true
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handleAuth!)
    }

}
