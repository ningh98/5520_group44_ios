//
//  FastingHistoryViewController.swift
//  5520_IOS_Group44
//
//  Created by Lambert on 2024/12/4.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

enum TimeSpan: String, CaseIterable {
    case week = "1 Week"
    case month = "1 Month"
    case threeMonths = "3 Month"
    case year = "1 Year"
    
    var days: Int {
        switch self {
        case .week: return 7
        case .month: return 30
        case .threeMonths: return 90
        case .year: return 365
        }
    }
    
    var interval: Calendar.Component {
        switch self {
        case .week: return .day
        case .month: return .weekOfMonth
        case .threeMonths: return .month
        case .year: return .month
        }
    }
    
    var intervalCount: Int {
        switch self {
        case .week: return 1
        case .month: return 1
        case .threeMonths: return 2
        case .year: return 2
        }
    }
}

class FastingHistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var fastingSessions: [Log] = []
    private let dayFormatter = DateFormatter()
    private let timeFormatter = DateFormatter()
    private var currentTimeSpan: TimeSpan = .week
    
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
        return view
    }()
    
    lazy var timeSpanButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(currentTimeSpan.rawValue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        button.semanticContentAttribute = .forceRightToLeft
        button.addTarget(self, action: #selector(showTimeSpanMenu), for: .touchUpInside)
        return button
    }()
    
    var currentUser: FirebaseAuth.User? {
        return Auth.auth().currentUser
    }
    let db = Firestore.firestore()

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
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Add time span button at the top
        let buttonContainer = UIView(frame: CGRect(x: 0, y: 20, width: view.bounds.width, height: 44))
        buttonContainer.backgroundColor = .clear
        timeSpanButton.frame = CGRect(x: (buttonContainer.bounds.width - 120) / 2, y: 0, width: 120, height: 44)
        buttonContainer.addSubview(timeSpanButton)
        view.addSubview(buttonContainer)
        
        // Adjust other views' positions
        let topMargin = buttonContainer.frame.maxY + 10
        diagramView.frame = CGRect(x: 20, 
                                 y: topMargin,
                                 width: UIScreen.main.bounds.size.width-40,
                                 height: DiagramViewCell.height()+60+20)
        
        table.frame = CGRect(x: 0,
                           y: diagramView.frame.maxY,
                           width: view.bounds.width,
                           height: view.bounds.height - diagramView.frame.maxY)
        
        view.addSubview(diagramView)
        view.addSubview(table)
        
        // Register the custom cell
        table.register(HistoryTableViewCell.self, forCellReuseIdentifier: "HistoryCell")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dayFormatter.dateFormat = "yyyy-MM-dd"
        timeFormatter.dateFormat = "MM-dd HH:mm"
        
        setupUI()
        setupTimeSpanMenu()
        makeDaysData()
    }
    
    private func setupTimeSpanMenu() {
        let menu = UIMenu(title: "", children: TimeSpan.allCases.map { span in
            UIAction(title: span.rawValue) { [weak self] _ in
                self?.updateTimeSpan(span)
            }
        })
        
        timeSpanButton.showsMenuAsPrimaryAction = true
        timeSpanButton.menu = menu
    }
    
    @objc private func showTimeSpanMenu() {
        
    }
    
    private func updateTimeSpan(_ span: TimeSpan) {
        currentTimeSpan = span
        timeSpanButton.setTitle(span.rawValue, for: .normal)
        makeDaysData()
    }
    
    func makeDaysData() {
        let calendar = Calendar.current
        let dayFormatter = DateFormatter()
        var daysArray: [FastingLog] = []
        var lastDate = Date()
        
        switch currentTimeSpan {
        case .week:
            dayFormatter.dateFormat = "E"  // Show day of week (Mon, Tue, etc.)
            // Generate data for each day in the week
            for _ in 0..<7 {
                let dateStr = dayFormatter.string(from: lastDate)
                daysArray.append(FastingLog(date: lastDate, dateString: dateStr, duration: 0))
                if let previousDate = calendar.date(byAdding: .day, value: -1, to: lastDate) {
                    lastDate = previousDate
                }
            }
            
        case .month:
            dayFormatter.dateFormat = "MM/dd"  // Show month/day format
            // Generate data for each day in the month
            for _ in 0..<30 {
                let dateStr = dayFormatter.string(from: lastDate)
                daysArray.append(FastingLog(date: lastDate, dateString: dateStr, duration: 0))
                if let previousDate = calendar.date(byAdding: .day, value: -1, to: lastDate) {
                    lastDate = previousDate
                }
            }
            
        case .threeMonths:
            dayFormatter.dateFormat = "MM/dd"  // Show month/day for weeks
            // Generate data for each week in three months
            for _ in 0..<12 {  // 12 weeks in 3 months
                let dateStr = dayFormatter.string(from: lastDate)
                daysArray.append(FastingLog(date: lastDate, dateString: dateStr, duration: 0))
                if let previousDate = calendar.date(byAdding: .weekOfMonth, value: -1, to: lastDate) {
                    lastDate = previousDate
                }
            }
            
        case .year:
            dayFormatter.dateFormat = "MMM"  // Show month name (Jan, Feb, etc.)
            // Generate data for each month in the year
            for _ in 0..<12 {  // 12 months
                let dateStr = dayFormatter.string(from: lastDate)
                daysArray.append(FastingLog(date: lastDate, dateString: dateStr, duration: 0))
                if let previousDate = calendar.date(byAdding: .month, value: -1, to: lastDate) {
                    lastDate = previousDate
                }
            }
        }
        
        // Calculate total duration for each time period
        for log in fastingSessions {
            if let date = log.fastingData?.startTime, let duration = log.fastingData?.duration {
                // Find the appropriate time period for this log
                switch currentTimeSpan {
                case .week:
                    // Daily aggregation
                    if let index = daysArray.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: date) }) {
                        daysArray[index].duration += duration
                    }
                case .month:
                    // Daily aggregation
                    if let index = daysArray.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: date) }) {
                        daysArray[index].duration += duration
                    }
                case .threeMonths:
                    // Weekly aggregation
                    if let index = daysArray.firstIndex(where: { 
                        calendar.isDate(date, equalTo: $0.date, toGranularity: .weekOfMonth)
                    }) {
                        daysArray[index].duration += duration
                    }
                case .year:
                    // Monthly aggregation
                    if let index = daysArray.firstIndex(where: { 
                        calendar.isDate(date, equalTo: $0.date, toGranularity: .month)
                    }) {
                        daysArray[index].duration += duration
                    }
                }
            }
        }
        
        // Convert TimeSpan to DiagramView.DisplayMode
        let displayMode: DiagramView.DisplayMode
        switch currentTimeSpan {
        case .week:
            displayMode = .week
        case .month:
            displayMode = .month
        case .threeMonths, .year:
            displayMode = .year
        }
        
        diagramView.refresh(logs: daysArray.reversed(), mode: displayMode)
        table.reloadData()
    }
    
    private func getPreviousDate(_ date: Date) -> Date? {
        let calendar = Calendar.current
        return calendar.date(byAdding: .day, value: -1, to: date)
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
            textField.placeholder = "Start Time (MM/dd/yyyy HH:mm)"
            textField.text = DateFormatter.localizedString(from: session.fastingData?.startTime ?? Date(), dateStyle: .medium, timeStyle: .short)
        }

        alertController.addTextField { textField in
            textField.placeholder = "End Time (MM/dd/yyyy HH:mm)"
            textField.text = DateFormatter.localizedString(from: session.fastingData?.endTime ?? Date(), dateStyle: .medium, timeStyle: .short)
        }

        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let self = self else { return }
            guard let startText = alertController.textFields?[0].text,
                  let endText = alertController.textFields?[1].text,
                  let newStartTime = self.parseDate(from: startText),
                  let newEndTime = self.parseDate(from: endText) else {
                
                self.showAlert(title: "Invalid Format", 
                             message: "Please enter dates in the format: MM/dd/yyyy HH:mm (e.g., 12/07/2024 15:30)")
                return
            }
            
            
            if newEndTime <= newStartTime {
                self.showAlert(title: "Invalid Time Range", 
                             message: "End time must be after start time")
                return
            }
            
            
            let timeInterval = newEndTime.timeIntervalSince(newStartTime)
            if timeInterval > 7 * 24 * 3600 {
                self.showAlert(title: "Invalid Duration", 
                             message: "Fasting duration cannot exceed 7 days")
                return
            }
            
            
            self.showConfirmationAlert(title: "Confirm Changes", 
                                     message: "Are you sure you want to update this fasting record?") { [weak self] confirmed in
                guard let self = self else { return }
                if confirmed {
                    
                    self.fastingSessions[indexPath.row].fastingData?.startTime = newStartTime
                    self.fastingSessions[indexPath.row].fastingData?.endTime = newEndTime
                    
                    
                    self.updateFastingSession(self.fastingSessions[indexPath.row], 
                                            newStartTime: newStartTime, 
                                            newEndTime: newEndTime) { success in
                        if success {
                            NotificationCenter.default.post(name: Notification.Name("FastingDataUpdated"), 
                                                         object: nil)
                            DispatchQueue.main.async {
                                self.table.reloadRows(at: [indexPath], with: .automatic)
                                self.showAlert(title: "Success", 
                                             message: "Fasting record updated successfully")
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.showAlert(title: "Error", 
                                             message: "Failed to update fasting record")
                            }
                        }
                    }
                }
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, 
                                    message: message, 
                                    preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showConfirmationAlert(title: String, 
                                     message: String, 
                                     completion: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: title, 
                                    message: message, 
                                    preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completion(false)
        })
        
        alert.addAction(UIAlertAction(title: "Confirm", style: .default) { _ in
            completion(true)
        })
        
        present(alert, animated: true)
    }

}

// MARK: - HistoryTableViewCellDelegate
extension FastingHistoryViewController: HistoryTableViewCellDelegate {
    func didTapDeleteButton(in cell: HistoryTableViewCell) {
        guard let indexPath = table.indexPath(for: cell) else { return }
        let session = fastingSessions[indexPath.row]
        
        
        showConfirmationAlert(title: "Delete Record", 
                            message: "Are you sure you want to delete this fasting record? This action cannot be undone.") { [weak self] confirmed in
            guard let self = self else { return }
            if confirmed {
                
                self.deleteSession(session) { success in
                    DispatchQueue.main.async {
                        if success {
                            self.showAlert(title: "Success", 
                                         message: "Fasting record deleted successfully")
                            
                            self.fastingSessions.remove(at: indexPath.row)
                            self.table.deleteRows(at: [indexPath], with: .fade)
                            
                            NotificationCenter.default.post(name: Notification.Name("FastingDataUpdated"), object: nil)
                        } else {
                            self.showAlert(title: "Error", 
                                         message: "Failed to delete fasting record")
                        }
                    }
                }
            }
        }
    }

    func didTapEditButton(in cell: HistoryTableViewCell) {
        guard let indexPath = table.indexPath(for: cell) else { return }
        let session = fastingSessions[indexPath.row]
        showEditTimeDialog(for: session, at: indexPath)
    }
}
