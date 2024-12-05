//
//  FastingHistoryViewController.swift
//  5520_IOS_Group44
//
//  Created by Lambert on 2024/12/4.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class FastingHistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var fastingSessions: [Log] = []
    private let dayFormatter = DateFormatter()
    private let timeFormatter = DateFormatter()
    
    var currentUser: FirebaseAuth.User? {
        return Auth.auth().currentUser
    }
    let db = Firestore.firestore()

    let diagramView: DiagramView = {
        let view = DiagramView()
        view.frame = CGRectMake(20, 0, UIScreen.main.bounds.size.width-40, DiagramViewCell.height()+60+20)
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.shadowOffset = CGSize(width: -3, height: -3)
        view.layer.shadowRadius = 6
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        return view
    }()

    lazy var header: UIView = {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 60))
        
        let view = UILabel()
        view.text = "History"
        view.frame = CGRect(x: 10, y: 0, width: 200, height: 60)
        view.font = .systemFont(ofSize: 22, weight: .bold)
        
        header.addSubview(view)
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 0.91, green: 0.41, blue: 0.54, alpha: 1.0).cgColor, // Pink
            UIColor(red: 0.57, green: 0.35, blue: 0.93, alpha: 1.0).cgColor  // Purple
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.frame = view.bounds
        gradientLayer.mask = view.layer
        header.layer.addSublayer(gradientLayer)
        return header
    }()
    
    
    lazy var table: UITableView = {
        let view = UITableView(frame: CGRect(x: 0, y: DiagramViewCell.height()+60+20, width: self.view.bounds.size.width, height: self.view.bounds.size.height-(DiagramViewCell.height()+60+20)), style: .insetGrouped)
        view.dataSource = self
        view.delegate = self
//        view.tableHeaderView = self.header
        return view
    }()
    
    init(fastingSessions: [Log]) {
        self.fastingSessions = fastingSessions
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reloadData(_ logs: [Log]) {
        fastingSessions = logs
        makeDaysData()
        table.reloadData()
    }
    
    func makeDaysData() {
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "MM/dd"
        var daysArray: [FastingLog] = []
        //确保显示当前日期的数据
        var lastDate = Date()
        let dateStr = dayFormatter.string(from: lastDate)
        daysArray.append(FastingLog(date: lastDate, dateString: dateStr, duration: 0))
        
        for log in fastingSessions {
            if let date = log.fastingData?.startTime, let duration = log.fastingData?.duration {
                lastDate = date
                let dateStr = dayFormatter.string(from: date)
                var lastObj = daysArray.last
                if lastObj == nil {
                    daysArray.append(FastingLog(date: date, dateString: dateStr, duration: duration))
                } else if lastObj!.dateString == dateStr {
                    lastObj!.duration = lastObj!.duration + duration
                }
            }
        }
        
        //不满7天历史数据的话至少填充满7天数据
        if daysArray.count < 7 {
            let calendar = Calendar.current
            if daysArray.count > 0 && calendar.isDate(lastDate, inSameDayAs: Date()) {
                if let previousDate = getPreviousDate(lastDate) {
                    lastDate = previousDate
                }
            }
            for _ in 0..<7-daysArray.count {
                let dateStr = dayFormatter.string(from: lastDate)
                daysArray.append(FastingLog(date: lastDate, dateString: dateStr, duration: 0))
                if let previousDate = getPreviousDate(lastDate) {
                    lastDate = previousDate
                }
            }
        }
        
        diagramView.refresh(logs: daysArray.reversed())
    }
    
    private func getPreviousDate(_ date: Date) -> Date? {
        let calendar = Calendar.current
        return calendar.date(byAdding: .day, value: -1, to: date)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "History"
        
        dayFormatter.dateFormat = "yyyy-MM-dd"
        timeFormatter.dateFormat = "MM-dd HH:mm"
        
        view.backgroundColor = .groupTableViewBackground
        view.addSubview(diagramView)
        view.addSubview(table)
        
        // Register the custom cell
        table.register(HistoryTableViewCell.self, forCellReuseIdentifier: "HistoryCell")
        
        let navHeight = 30.0
        diagramView.frame = CGRectMake(20, navHeight, UIScreen.main.bounds.size.width-40, DiagramViewCell.height()+60+20)
        table.frame = CGRect(x: 0, y: CGRectGetMaxY(diagramView.frame), width: self.view.bounds.size.width, height: self.view.bounds.size.height-CGRectGetMaxY(diagramView.frame)-30)
        
        makeDaysData()
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return header
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fastingSessions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath) as! HistoryTableViewCell
        let log = fastingSessions[indexPath.item]

        // Set up the cell's labels
        if let startDate = log.fastingData?.startTime {
            cell.dateLabel.text = dayFormatter.string(from: startDate)
            if let endDate = log.fastingData?.endTime {
                cell.timeRangeLabel.text = "\(timeFormatter.string(from: startDate)) to \(timeFormatter.string(from: endDate))"
            }
        }

        // Set up button actions
        cell.delegate = self
        return cell
    }

    
    private func deleteSession(_ session: Log, completion: @escaping (Bool) -> Void) {
        guard let user = currentUser else {
            print("Invalid user.")
            completion(false)
            return
        }

        let dateTolerance: TimeInterval = 1 // 1-second tolerance
        let startRange = session.date.addingTimeInterval(-dateTolerance)
        let endRange = session.date.addingTimeInterval(dateTolerance)

        db.collection("users")
            .document(user.uid)
            .collection("fasting_sessions")
            .whereField("date", isGreaterThanOrEqualTo: startRange)
            .whereField("date", isLessThanOrEqualTo: endRange)
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error finding session to delete: \(error)")
                    completion(false)
                    return
                }

                guard let document = querySnapshot?.documents.first else {
                    print("No matching session found to delete.")
                    completion(false)
                    return
                }

                document.reference.delete { error in
                    if let error = error {
                        print("Error deleting session: \(error)")
                        completion(false)
                    } else {
                        // Remove the session locally
                        if let index = self.fastingSessions.firstIndex(where: { $0.date == session.date }) {
                            self.fastingSessions.remove(at: index)
                        }

                        // Notify other controllers of the update
                        NotificationCenter.default.post(name: Notification.Name("FastingDataUpdated"), object: nil)

                        // Update the table view
                        DispatchQueue.main.async {
                            self.table.reloadData()
                        }

                        print("Session deleted successfully.")
                        completion(true)
                    }
                }
            }
    }

    
    private func updateFastingSession(_ session: Log, newStartTime: Date, newEndTime: Date, completion: @escaping (Bool) -> Void) {
        guard let user = currentUser else {
            print("Current user is nil.")
            completion(false)
            return
        }

        let dateTolerance: TimeInterval = 1 // 1-second tolerance
        let startRange = session.date.addingTimeInterval(-dateTolerance)
        let endRange = session.date.addingTimeInterval(dateTolerance)

        print("Attempting to update session with date between \(startRange) and \(endRange)")

        db.collection("users")
            .document(user.uid)
            .collection("fasting_sessions")
            .whereField("date", isGreaterThanOrEqualTo: startRange)
            .whereField("date", isLessThanOrEqualTo: endRange)
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error finding session to update: \(error)")
                    completion(false)
                    return
                }

                guard let document = querySnapshot?.documents.first else {
                    print("No matching session found to update.")
                    completion(false)
                    return
                }

                print("Updating session with document ID: \(document.documentID)")

                let updatedData: [String: Any] = [
                    "fastingData.startTime": Timestamp(date: newStartTime),
                    "fastingData.endTime": Timestamp(date: newEndTime)
                ]

                document.reference.updateData(updatedData) { error in
                    if let error = error {
                        print("Error updating session: \(error)")
                        completion(false)
                    } else {
                        print("Session updated successfully.")
                        completion(true)
                    }
                }
            }
    }

    
    private func parseDate(from dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter.date(from: dateString)
    }
    
    private func showEditTimeDialog(for session: Log, at indexPath: IndexPath) {
        let alertController = UIAlertController(title: "Edit Times", message: nil, preferredStyle: .alert)

        alertController.addTextField { textField in
            textField.placeholder = "Start Time"
            textField.text = DateFormatter.localizedString(from: session.fastingData?.startTime ?? Date(), dateStyle: .medium, timeStyle: .short)
        }

        alertController.addTextField { textField in
            textField.placeholder = "End Time"
            textField.text = DateFormatter.localizedString(from: session.fastingData?.endTime ?? Date(), dateStyle: .medium, timeStyle: .short)
        }

        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let self = self else { return }
            guard let startText = alertController.textFields?[0].text,
                  let endText = alertController.textFields?[1].text,
                  let newStartTime = self.parseDate(from: startText),
                  let newEndTime = self.parseDate(from: endText) else {
                print("Invalid date input")
                return
            }

            // Update the local session
            self.fastingSessions[indexPath.row].fastingData?.startTime = newStartTime
            self.fastingSessions[indexPath.row].fastingData?.endTime = newEndTime

            // Update Firestore
            self.updateFastingSession(self.fastingSessions[indexPath.row], newStartTime: newStartTime, newEndTime: newEndTime) { success in
                if success {
                    // Notify other controllers
                    NotificationCenter.default.post(name: Notification.Name("FastingDataUpdated"), object: nil)

                    // Refresh the UI
                    DispatchQueue.main.async {
                        self.table.reloadRows(at: [indexPath], with: .automatic)
                    }
                } else {
                    print("Failed to update session")
                }
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true)
    }

    
    



}

extension FastingHistoryViewController: HistoryTableViewCellDelegate {
    func didTapDeleteButton(in cell: HistoryTableViewCell) {
        guard let indexPath = table.indexPath(for: cell) else { return }
        let session = fastingSessions[indexPath.row]

        // Perform the deletion
        deleteSession(session) { success in
            if success {
                print("Session deleted successfully.")
            } else {
                print("Failed to delete session")
            }
        }
    }


    func didTapEditButton(in cell: HistoryTableViewCell) {
        guard let indexPath = table.indexPath(for: cell) else { return }
        let session = fastingSessions[indexPath.row]
        showEditTimeDialog(for: session, at: indexPath)
    }
    
    
}

