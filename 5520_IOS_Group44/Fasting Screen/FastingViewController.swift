//
//  FastingViewController.swift
//  5520_IOS_Group44
//
//  Created by Ninghui Cai on 11/21/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class FastingViewController: UIViewController {
    let fastingView = FastingView()
    var currentUser: FirebaseAuth.User?
    var timer: Timer?
    var startTime: Date?
    var endTime: Date?
    var targetDuration: TimeInterval = 16 * 3600 // 16 hours in seconds
    var fastingSessions: [Log] = []
    let db = Firestore.firestore()
    
    private var startFastingView: StartFastingView?
    private var dimmedBackgroundView: UIView?
    
    override func loadView() {
        view = fastingView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        loadLastFastingSession()
        loadFastingHistory()
        
        // 添加调试信息
        print("ViewDidLoad completed")
        print("Action button frame: \(fastingView.actionButton.frame)")
        print("Action button isUserInteractionEnabled: \(fastingView.actionButton.isUserInteractionEnabled)")
        print("Action button allTargets: \(fastingView.actionButton.allTargets)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 确保视图出现时状态正确
        startTime = nil
        endTime = nil
        updateUI()
        fastingView.updateForFastingState(isFasting: false)
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Fasting Timer"
        navigationController?.navigationBar.prefersLargeTitles = true
        updateTargetTimeDisplay()
    }
    
    private func setupActions() {
        print("Setting up actions") // Debug print
        
        // Main fasting view button
        fastingView.actionButton.isUserInteractionEnabled = true
        fastingView.actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        
        print("Action button target added") // Debug print
    }
    
    @objc private func actionButtonTapped() {
        print("Action button tapped - Current startTime: \(String(describing: startTime))") // Debug print
        if startTime == nil {
            print("Starting new fasting session") // Debug print
            DispatchQueue.main.async {
                self.showStartFastingDialog()
            }
        } else {
            print("Ending current fasting session") // Debug print
            endFasting()
        }
    }
    
    private func showTimePicker(for type: TimePickerType) {
        let alert = UIAlertController(style: .actionSheet)
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .time
        datePicker.preferredDatePickerStyle = .wheels
        
        alert.view.addSubview(datePicker)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            datePicker.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 20),
            datePicker.leadingAnchor.constraint(equalTo: alert.view.leadingAnchor, constant: 20),
            datePicker.trailingAnchor.constraint(equalTo: alert.view.trailingAnchor, constant: -20),
            datePicker.heightAnchor.constraint(equalToConstant: 200)
        ])
        
        alert.addAction(UIAlertAction(title: "Done", style: .default) { [weak self] _ in
            self?.updateTime(datePicker.date, for: type)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func updateTime(_ date: Date, for type: TimePickerType) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        switch type {
        case .start:
            fastingView.startTimeCard.timeLabel.text = "Today, \(formatter.string(from: date))"
        case .goal:
            fastingView.goalTimeCard.timeLabel.text = "Tomorrow, \(formatter.string(from: date))"
        }
        
        updateTargetDuration()
    }
    
    private func startFasting() {
        startTime = Date()
        endTime = nil
        startTimer()
        updateUI()
        saveFastingSession()
        fastingView.updateForFastingState(isFasting: true)
    }
    
    private func endFasting() {
        print("Ending fasting session") // Debug print
        guard let start = startTime else { return }
        
        // 保存结束时间
        endTime = Date()
        
        // 停止计时器
        timer?.invalidate()
        timer = nil
        
        // 重置状态
        startTime = nil
        endTime = nil
        
        // 更新UI
        updateUI()
        fastingView.updateForFastingState(isFasting: false)
        
        print("Fasting session ended, state reset") // Debug print
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateUI()
        }
    }
    
    private func updateUI() {
        if let start = startTime {
            let duration = (endTime ?? Date()).timeIntervalSince(start)
            let progress = min(duration / targetDuration, 1.0)
            
            // Update progress ring
            fastingView.progressView.setProgress(to: CGFloat(progress))
            
            // Format "Fasting For" time (minutes:seconds)
            let fastingMinutes = Int(duration) / 60
            let fastingSeconds = Int(duration) % 60
            fastingView.timerLabel.text = String(format: "%02d:%02d", fastingMinutes, fastingSeconds)
            
            // Format "Left" time (hours:minutes:seconds)
            let remainingTime = max(targetDuration - duration, 0)
            let remainingHours = Int(remainingTime) / 3600
            let remainingMinutes = (Int(remainingTime) % 3600) / 60
            let remainingSeconds = Int(remainingTime) % 60
            fastingView.remainingLabel.text = String(format: "%02d:%02d:%02d left", remainingHours, remainingMinutes, remainingSeconds)
            
            // Update start time and end time display
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            
            let startTimeString = dateFormatter.string(from: start)
            fastingView.startTimeCard.timeLabel.text = startTimeString
            
            let end = start.addingTimeInterval(targetDuration)
            let endTimeString = dateFormatter.string(from: end)
            fastingView.goalTimeCard.timeLabel.text = endTimeString
            
        } else {
            // Reset all displays
            fastingView.progressView.setProgress(to: 0)
            fastingView.timerLabel.text = "00:00"
            fastingView.remainingLabel.text = "00:00:00 left"
            fastingView.startTimeCard.timeLabel.text = "Not set"
            fastingView.goalTimeCard.timeLabel.text = "Not set"
        }
    }
    
    private func updateTargetTimeDisplay() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        let now = Date()
        let calendar = Calendar.current
        
        // 设置默认开始时间为晚上8点
        var startComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: now)
        startComponents.hour = 20
        startComponents.minute = 0
        if let defaultStart = calendar.date(from: startComponents) {
            fastingView.startTimeCard.timeLabel.text = "Today, \(formatter.string(from: defaultStart))"
        }
        
        // 设置默认结束时间为第二天中午12点
        var endComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: now)
        endComponents.day! += 1
        endComponents.hour = 12
        endComponents.minute = 0
        if let defaultEnd = calendar.date(from: endComponents) {
            fastingView.goalTimeCard.timeLabel.text = "Tomorrow, \(formatter.string(from: defaultEnd))"
        }
    }
    
    private func updateTargetDuration() {
        let startDateString = fastingView.startTimeCard.timeLabel.text?.components(separatedBy: ", ")[1] ?? ""
        let endDateString = fastingView.goalTimeCard.timeLabel.text?.components(separatedBy: ", ")[1] ?? ""
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        if let startDate = formatter.date(from: startDateString),
           let endDate = formatter.date(from: endDateString) {
            let interval = endDate.timeIntervalSince(startDate)
            targetDuration = interval
        }
    }
    
    private func saveFastingSession() {
        guard let user = currentUser,
              let start = startTime else { return }
        
        let fastingData = FastingData(startTime: start, endTime: endTime ?? Date())
        
        let log = Log(date: start, 
                     comment: "Fasting Session",
                     fastingData: fastingData)
        
        // 将 Log 对象转换为字典
        let data: [String: Any] = [
            "date": log.date,
            "comment": log.comment,
            "fastingData": [
                "startTime": fastingData.startTime,
                "endTime": fastingData.endTime
            ]
        ]
        
        db.collection("users")
            .document(user.uid)
            .collection("fasting_sessions")
            .addDocument(data: data) { [weak self] error in
                if let error = error {
                    print("Error saving fasting session: \(error)")
                    return
                }
                
                // 更新本地数据
                self?.fastingSessions.insert(log, at: 0)
            }
    }
    
    func loadLastFastingSession() {
        guard let user = currentUser else { return }
        
        db.collection("users")
            .document(user.uid)
            .collection("fasting_sessions")
            .order(by: "date", descending: true)
            .limit(to: 1)
            .getDocuments { [weak self] querySnapshot, error in
                if let error = error {
                    print("Error loading last fasting session: \(error)")
                    return
                }
                
                if let document = querySnapshot?.documents.first,
                   let date = document.data()["date"] as? Timestamp,
                   let comment = document.data()["comment"] as? String,
                   let fastingDataDict = document.data()["fastingData"] as? [String: Any],
                   let startTime = (fastingDataDict["startTime"] as? Timestamp)?.dateValue(),
                   let endTime = (fastingDataDict["endTime"] as? Timestamp)?.dateValue() {
                    
                    let fastingData = FastingData(startTime: startTime, endTime: endTime)
                    let log = Log(date: date.dateValue(), 
                                comment: comment,
                                fastingData: fastingData)
                    
                    self?.startTime = fastingData.startTime
                    self?.endTime = fastingData.endTime
                    if self?.endTime == nil {
                        self?.startTimer()
                    }
                    self?.updateUI()
                }
            }
    }
    
    func loadFastingHistory() {
        guard let user = currentUser else { return }
        
        db.collection("users")
            .document(user.uid)
            .collection("fasting_sessions")
            .order(by: "date", descending: true)
            .getDocuments { [weak self] querySnapshot, error in
                if let error = error {
                    print("Error loading fasting history: \(error)")
                    return
                }
                
                self?.fastingSessions = querySnapshot?.documents.compactMap { document in
                    guard let date = (document.data()["date"] as? Timestamp)?.dateValue(),
                          let comment = document.data()["comment"] as? String,
                          let fastingDataDict = document.data()["fastingData"] as? [String: Any],
                          let startTime = (fastingDataDict["startTime"] as? Timestamp)?.dateValue(),
                          let endTime = (fastingDataDict["endTime"] as? Timestamp)?.dateValue() else {
                        return nil
                    }
                    
                    let fastingData = FastingData(startTime: startTime, endTime: endTime)
                    return Log(date: date, 
                             comment: comment,
                             fastingData: fastingData)
                } ?? []
            }
    }
    
    private func showStartFastingDialog() {
        print("Showing start fasting dialog") // Debug print
        
        // 计算安全区域
        let safeAreaBottom = view.safeAreaInsets.bottom
        let dialogHeight: CGFloat = 400
        
        // 创建并设置 StartFastingView，考虑底部安全区域
        startFastingView = StartFastingView(frame: CGRect(x: 0,
                                                         y: view.bounds.height,
                                                         width: view.bounds.width,
                                                         height: dialogHeight))
        
        // 创建半透明背景
        dimmedBackgroundView = UIView(frame: view.bounds)
        dimmedBackgroundView?.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        dimmedBackgroundView?.alpha = 0
        
        guard let dimmedBackgroundView = dimmedBackgroundView,
              let startFastingView = startFastingView else {
            print("Failed to create views") // Debug print
            return
        }
        
        // 添加点击手势
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDimmedViewTap))
        dimmedBackgroundView.addGestureRecognizer(tapGesture)
        
        setupStartFastingDialog()
        
        // 更新初始时间显示
        updateStartFastingViewTimes()
        
        // 添加视图到层级
        view.addSubview(dimmedBackgroundView)
        view.addSubview(startFastingView)
        
        // 确保视图在最前面
        view.bringSubviewToFront(dimmedBackgroundView)
        view.bringSubviewToFront(startFastingView)
        
        print("Views added to hierarchy") // Debug print
        
        // 动画显示，考虑底部安全区域
        UIView.animate(withDuration: 0.3) {
            dimmedBackgroundView.alpha = 1
            startFastingView.frame.origin.y = self.view.bounds.height - dialogHeight - safeAreaBottom
        } completion: { finished in
            print("Animation completed: \(finished)") // Debug print
        }
    }
    
    private func setupStartFastingDialog() {
        print("Setting up start fasting dialog") // Debug print
        
        // 添加手势识别器
        let durationTap = UITapGestureRecognizer(target: self, action: #selector(showDurationPicker))
        startFastingView?.goalDurationValueLabel.isUserInteractionEnabled = true
        startFastingView?.goalDurationValueLabel.addGestureRecognizer(durationTap)
        
        let startTimeTap = UITapGestureRecognizer(target: self, action: #selector(showStartTimePicker))
        startFastingView?.startTimeValueLabel.isUserInteractionEnabled = true
        startFastingView?.startTimeValueLabel.addGestureRecognizer(startTimeTap)
        
        // 设置按钮动作
        startFastingView?.startButton.addTarget(self, action: #selector(startFastingButtonTapped), for: .touchUpInside)
        startFastingView?.cancelButton.addTarget(self, action: #selector(cancelStartFastingButtonTapped), for: .touchUpInside)
    }
    
    @objc private func handleDimmedViewTap() {
        dismissStartFastingDialog()
    }
    
    private func dismissStartFastingDialog() {
        guard let dimmedBackgroundView = dimmedBackgroundView,
              let startFastingView = startFastingView else { return }
        
        // 动画隐藏
        UIView.animate(withDuration: 0.3) {
            dimmedBackgroundView.alpha = 0
            startFastingView.frame.origin.y = self.view.bounds.height
        } completion: { _ in
            dimmedBackgroundView.removeFromSuperview()
            startFastingView.removeFromSuperview()
            self.dimmedBackgroundView = nil
            self.startFastingView = nil
        }
    }
    
    @objc private func cancelStartFastingButtonTapped() {
        dismissStartFastingDialog()
    }
    
    private func updateStartFastingViewTimes() {
        guard let startFastingView = startFastingView else { return }
        
        // Update duration
        let hours = Int(targetDuration / 3600)
        startFastingView.goalDurationValueLabel.text = "\(hours)h"
        
        // Update start time
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        let startDate = startTime ?? Date()
        let calendar = Calendar.current
        let isToday = calendar.isDateInToday(startDate)
        let startTimeText = isToday ? "Today" : "Tomorrow"
        startFastingView.startTimeValueLabel.text = "\(startTimeText), \(dateFormatter.string(from: startDate))"
        
        // Update goal time
        let endDate = startDate.addingTimeInterval(targetDuration)
        let isEndToday = calendar.isDateInToday(endDate)
        let endTimeText = isEndToday ? "Today" : "Tomorrow"
        startFastingView.goalTimeValueLabel.text = "\(endTimeText), \(dateFormatter.string(from: endDate))"
    }
    
    @objc private func startFastingButtonTapped() {
        hideStartFastingDialog()
        startFasting()
    }
    
    private func hideStartFastingDialog() {
        UIView.animate(withDuration: 0.3, animations: {
            self.dimmedBackgroundView?.alpha = 0
            self.startFastingView?.frame.origin.y = self.view.bounds.height
        }) { _ in
            self.startFastingView?.removeFromSuperview()
            self.dimmedBackgroundView?.removeFromSuperview()
            self.startFastingView = nil
            self.dimmedBackgroundView = nil
        }
    }
    
    @objc private func showDurationPicker() {
        let alert = UIAlertController(title: "Choose Duration", message: nil, preferredStyle: .actionSheet)
        let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: view.bounds.width - 16, height: 200))
        pickerView.delegate = self
        pickerView.dataSource = self
        
        // 设置初始选择
        let hours = Int(targetDuration / 3600)
        pickerView.selectRow(hours - 1, inComponent: 0, animated: false)
        
        let contentViewController = UIViewController()
        contentViewController.view = pickerView
        alert.setValue(contentViewController, forKey: "contentViewController")
        
        let doneAction = UIAlertAction(title: "Finish", style: .default) { [weak self] _ in
            let selectedHours = pickerView.selectedRow(inComponent: 0) + 1
            self?.targetDuration = TimeInterval(selectedHours * 3600)
            self?.updateStartFastingViewTimes()
        }
        
        alert.addAction(doneAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // 调整alert视图高度以适应选择器
        alert.view.heightAnchor.constraint(equalToConstant: 350).isActive = true
        
        present(alert, animated: true)
    }
    
    @objc private func showStartTimePicker() {
        let alert = UIAlertController(title: "Choose Start Time", message: nil, preferredStyle: .actionSheet)
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .time
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.date = Date()
        
        let contentViewController = UIViewController()
        contentViewController.view = datePicker
        alert.setValue(contentViewController, forKey: "contentViewController")
        
        let doneAction = UIAlertAction(title: "Finish", style: .default) { [weak self] _ in
            self?.startTime = datePicker.date
            self?.updateStartFastingViewTimes()
        }
        
        alert.addAction(doneAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // 调整alert视图高度以适应选择器
        alert.view.heightAnchor.constraint(equalToConstant: 350).isActive = true
        
        present(alert, animated: true)
    }
}

enum TimePickerType {
    case start
    case goal
}

extension UIAlertController {
    convenience init(style: UIAlertController.Style) {
        self.init(title: nil, message: nil, preferredStyle: style)
    }
}

extension FastingViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 24 // 1-24 hours
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(row + 1) hours"
    }
}
