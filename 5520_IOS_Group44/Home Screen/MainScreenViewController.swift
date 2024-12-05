//
//  MainScreenViewController.swift
//  5520_IOS_Group44
//
//  Created by Ninghui Cai on 11/21/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

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
                
                // Fetch logs from Firestore
                if let userId = user?.uid {
                    self.fetchLogs(for: userId)
                }
    
                //MARK: Logout bar button...
                self.setupRightBarButton(isLoggedin: true)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Home"
        
        // Set up button action
        mainScreenView.addLogButton.addTarget(self, action: #selector(addLogTapped), for: .touchUpInside)

        
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
    
    @objc private func addLogTapped() {
        let addLogVC = AddLogViewController()
        addLogVC.saveAction = { [weak self] date, comment in
            guard let self = self, let user = self.currentUser else { return }
            self.saveLogToFirestore(userId: user.uid, date: date, comment: comment)
        }
        present(addLogVC, animated: true, completion: nil)
    }

}


extension MainScreenViewController {
    func saveLogToFirestore(userId: String, date: Date, comment: String) {
        let db = Firestore.firestore()
        let logData: [String: Any] = [
            "date": Timestamp(date: date),
            "comment": comment
        ]
        
        db.collection("users").document(userId).collection("logs").addDocument(data: logData) { error in
            if let error = error {
                print("Error saving log: \(error)")
            } else {
                print("Log saved successfully!")
                self.fetchLogs(for: userId) // Reload the logs to update the table
            }
        }
    }
    
    func fetchLogs(for userId: String) {
        let db = Firestore.firestore()
        db.collection("users").document(userId).collection("logs").order(by: "date", descending: true).getDocuments { snapshot, error in
            guard let documents = snapshot?.documents, error == nil else {
                print("Error fetching logs: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            self.logsList = documents.compactMap { doc in
                let data = doc.data()
                let date = (data["date"] as? Timestamp)?.dateValue() ?? Date()
                let comment = data["comment"] as? String ?? ""
                let logId = doc.documentID // Capture the document ID
                return Log(date: date, comment: comment, logId: logId)
            }
            
            DispatchQueue.main.async {
                self.mainScreenView.tableViewLogs.reloadData()
            }
        }
    }
    
    func showLogDetail(log: Log, logId: String) {
        let logDetailVC = LogDetailViewController()
        logDetailVC.log = log
        logDetailVC.logId = logId // Pass the Firestore-generated ID
        logDetailVC.currentUser = currentUser
        navigationController?.pushViewController(logDetailVC, animated: true)
    }
    
    

    
    
}


