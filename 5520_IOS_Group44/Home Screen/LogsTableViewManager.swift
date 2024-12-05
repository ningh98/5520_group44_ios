//
//  LogsTableViewManager.swift
//  5520_IOS_Group44
//
//  Created by Ninghui Cai on 11/21/24.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseFirestore

extension MainScreenViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Configs.tableViewLogsID, for: indexPath) as! LogsTableViewCell
        
        // Create a DateFormatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        // Convert Date to String
        let formattedDate = dateFormatter.string(from: logsList[indexPath.row].date)
        
        cell.labelDate.text = formattedDate
        cell.labelComment.text = logsList[indexPath.row].comment
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedLog = logsList[indexPath.row]
        let logId = selectedLog.logId!
        let logDetailVC = LogDetailViewController()
        logDetailVC.log = selectedLog
        logDetailVC.currentUser = currentUser
        navigateToLogDetail(for: selectedLog, logId: logId)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let logToDelete = logsList[indexPath.row]
            
            deleteLog(logId: logToDelete.logId!) { [weak self] success in
                guard let self = self else { return }
                if success {
                    self.logsList.remove(at: indexPath.row) // Remove from local array
                    DispatchQueue.main.async {
                        tableView.deleteRows(at: [indexPath], with: .automatic)
                    }
                } else {
                    print("Failed to delete log.")
                }
            }
        }
    }
    
    private func deleteLog(logId: String, completion: @escaping (Bool) -> Void) {
        guard let userId = currentUser?.uid else {
            completion(false)
            return
        }

        let db = Firestore.firestore()
        let logDocRef = db.collection("users").document(userId).collection("logs").document(logId)
        
        // Retrieve all meals in the log
        logDocRef.collection("meals").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching meals for deletion: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            let batch = db.batch()
            
            // For each meal, delete its `foods` subcollection and the meal document
            let dispatchGroup = DispatchGroup()
            snapshot?.documents.forEach { mealDoc in
                dispatchGroup.enter()
                let mealDocRef = mealDoc.reference
                mealDocRef.collection("foods").getDocuments { foodSnapshot, foodError in
                    if let foodError = foodError {
                        print("Error fetching foods for deletion: \(foodError.localizedDescription)")
                        dispatchGroup.leave()
                        return
                    }
                    
                    // Add deletion of all food documents to the batch
                    foodSnapshot?.documents.forEach { foodDoc in
                        batch.deleteDocument(foodDoc.reference)
                    }
                    
                    // Add deletion of the meal document itself to the batch
                    batch.deleteDocument(mealDocRef)
                    
                    dispatchGroup.leave()
                }
            }
            
            // After all meals and foods are handled, delete the log document itself
            dispatchGroup.notify(queue: .main) {
                batch.deleteDocument(logDocRef)
                
                // Commit the batch
                batch.commit { batchError in
                    if let batchError = batchError {
                        print("Error deleting log and its subcollections: \(batchError.localizedDescription)")
                        completion(false)
                    } else {
                        completion(true)
                    }
                }
            }
        }
    }
    
    


    
    private func navigateToLogDetail(for log: Log, logId: String) {
        let logDetailVC = LogDetailViewController()
        logDetailVC.log = log
        logDetailVC.logId = logId // Pass the Firestore-generated log ID
        logDetailVC.currentUser = currentUser // Pass the current user
        navigationController?.pushViewController(logDetailVC, animated: true)
    }
}
