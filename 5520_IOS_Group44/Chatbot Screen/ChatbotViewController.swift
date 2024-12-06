//
//  ChatbotViewController.swift
//  5520_IOS_Group44
//
//  Created by Bin Yang on 12/1/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

struct Message {
    let content: String
    let isFromUser: Bool
    let timestamp: Date
}

class ChatbotViewController: UIViewController {
    let chatbotView = ChatbotView()
    var messages: [Message] = []
    private let db = Firestore.firestore()
    private var currentUser: FirebaseAuth.User?
    private var userData: [String: Any]?
    private var caloriesData: [String: Any]?
    private var historicalCaloriesData: [[String: Any]] = []  // Store historical calories data
    private var recentMeals: [[String: Any]] = []
    
    // Grok API configuration
    private let apiUrl = "https://api.x.ai/v1/chat/completions"
    private let apiKey = "xai-83mvXcluXl4fMYAJYgNkkmQ2QHbVrCd9GpDTFl334s1iyvNOcOIkFkTW9AeBVW1VrAOtG68Sw8bDCLN6"
    
    private var conversationHistory: [[String: String]] = [
        [
            "role": "system",
            "content": """
            You are a professional health and fitness advisor with extensive knowledge in nutrition and exercise science. Your responsibilities include:

            1. Provide personalized health recommendations, including:
               - Diet planning and nutritional advice
               - Exercise program development
               - Lifestyle improvement suggestions
               - Health goal setting

            2. When responding, you should:
               - Use the user's profile data I provide to give personalized advice
               - Provide personalized advice based on user information
               - Use professional yet easy-to-understand language
               - Keep responses concise and focused
               - Be friendly but avoid formal signatures or greetings

            3. Your recommendations should include:
               - Specific exercise suggestions (type, duration, frequency)
               - Dietary recommendations based on their current nutrition data
               - Quantifiable goals
               - Precautions and warning information

            Important formatting rules:
            - Do not use Markdown formatting (no #, *, or other special characters)
            - Use plain text with simple formatting
            - Use normal capitalization and punctuation
            - Use clear sections with numbers or bullet points
            - Keep the text clean and easy to read
            - Never add signatures like 'Best regards' or your name at the end
            - Keep responses natural and conversational
            """
        ]
    ]
    
    override func loadView() {
        view = chatbotView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Health Advisor"
        setupTableView()
        setupActions()
        setupKeyboardHandling()
        
        currentUser = Auth.auth().currentUser
        loadUserData()
    }
    
    private func loadUserData() {
        guard let userId = currentUser?.uid else { return }
        
        // Load basic user data
        db.collection("users").document(userId).getDocument { [weak self] snapshot, error in
            if let error = error {
                print("Error loading user data: \(error)")
                return
            }
            
            guard let data = snapshot?.data() else {
                print("No user data found")
                return
            }
            
            self?.userData = data
            
            // After loading basic data, load calories data
            self?.loadCaloriesData()
        }
    }
    
    private func loadCaloriesData() {
        guard let userId = currentUser?.uid else { return }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: today)!
        
        var historicalData: [[String: Any]] = []
        let dispatchGroup = DispatchGroup()
        
        // Generate dates for the last 30 days
        var currentDate = today
        while currentDate >= thirtyDaysAgo {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateString = dateFormatter.string(from: currentDate)
            let capturedDate = currentDate
            
            dispatchGroup.enter()
            self.db.collection("users").document(userId)
                .collection("calorie_targets").document(dateString)
                .getDocument { [weak self] snapshot, error in
                    defer { dispatchGroup.leave() }
                    
                    var dayData: [String: Any] = [
                        "date": Timestamp(date: capturedDate),
                        "dailyCalories": 0.0,
                        "targetCalories": 2000 // default value
                    ]
                    
                    if let data = snapshot?.data() {
                        dayData["targetCalories"] = data["target_calories"] as? Int ?? 2000
                    }
                    
                    // Then get daily calories from meals/foods
                    dispatchGroup.enter()
                    self?.db.collection("users").document(userId)
                        .collection("logs").document(dateString)
                        .collection("meals")
                        .getDocuments { snapshot, error in
                            defer { dispatchGroup.leave() }
                            
                            var totalCalories: Double = 0
                            let foodGroup = DispatchGroup()
                            
                            if let documents = snapshot?.documents {
                                for mealDoc in documents {
                                    foodGroup.enter()
                                    self?.db.collection("users").document(userId)
                                        .collection("logs").document(dateString)
                                        .collection("meals").document(mealDoc.documentID)
                                        .collection("foods")
                                        .getDocuments { snapshot, error in
                                            defer { foodGroup.leave() }
                                            
                                            if let foodDocs = snapshot?.documents {
                                                for foodDoc in foodDocs {
                                                    let data = foodDoc.data()
                                                    if let calories = data["custom_calories"] as? Double {
                                                        totalCalories += calories
                                                        print("Found calories: \(calories) for date: \(dateString)")
                                                    }
                                                }
                                            }
                                        }
                                }
                            }
                            
                            foodGroup.notify(queue: .main) {
                                dayData["dailyCalories"] = totalCalories
                                historicalData.append(dayData)
                                print("Added data for \(dateString): Target: \(dayData["targetCalories"] ?? "nil"), Daily: \(totalCalories)")
                            }
                        }
                }
            
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            self?.historicalCaloriesData = historicalData.sorted {
                let date1 = ($0["date"] as? Timestamp)?.dateValue() ?? Date()
                let date2 = ($1["date"] as? Timestamp)?.dateValue() ?? Date()
                return date1 > date2
            }
            print("Final historical data count: \(historicalData.count)")
            self?.caloriesData = self?.historicalCaloriesData.first
            self?.loadRecentMeals()
        }
    }
    
    private func loadRecentMeals() {
        guard let userId = currentUser?.uid else { return }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: today)!
        var allMeals: [[String: Any]] = []
        let dispatchGroup = DispatchGroup()
        
        // Generate dates for the last 30 days
        var currentDate = today
        while currentDate >= thirtyDaysAgo {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateString = dateFormatter.string(from: currentDate)
            let capturedDate = currentDate
            
            dispatchGroup.enter()
            self.db.collection("users").document(userId)
                .collection("logs").document(dateString)
                .collection("meals")
                .getDocuments { [weak self] snapshot, error in
                    defer { dispatchGroup.leave() }
                    
                    if let documents = snapshot?.documents {
                        for mealDoc in documents {
                            dispatchGroup.enter()
                            self?.db.collection("users").document(userId)
                                .collection("logs").document(dateString)
                                .collection("meals").document(mealDoc.documentID)
                                .collection("foods")
                                .getDocuments { snapshot, error in
                                    defer { dispatchGroup.leave() }
                                    
                                    if let foodDocs = snapshot?.documents {
                                        for foodDoc in foodDocs {
                                            var foodData = foodDoc.data()
                                            foodData["date"] = Timestamp(date: capturedDate)
                                            foodData["meal_id"] = mealDoc.documentID
                                            allMeals.append(foodData)
                                            print("Added meal food: \(foodData["food_name"] ?? "unnamed") with calories: \(foodData["custom_calories"] ?? 0) for date: \(dateString)")
                                        }
                                    }
                                }
                        }
                    }
                }
            
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            self?.recentMeals = allMeals.sorted {
                let date1 = ($0["date"] as? Timestamp)?.dateValue() ?? Date()
                let date2 = ($1["date"] as? Timestamp)?.dateValue() ?? Date()
                return date1 > date2
            }
            print("Final meals count: \(allMeals.count)")
            
            // First show welcome message with user data
            if let data = self?.userData {
                self?.showPersonalizedWelcome(with: data)
            }
            
            // Then add historical data to the prompt
            self?.addUserDataToPrompt()
        }
    }
    
    private func showPersonalizedWelcome(with data: [String: Any]) {
        let name = data["userName"] as? String ?? "there"
        let height = data["height"] as? String ?? "not set"
        let currentWeight = data["currentWeight"] as? Int ?? 0
        let goalWeight = data["goalWeight"] as? Int ?? 0
        
        let welcomeMessage = """
        Hello \(name)!

        I see from your profile that:
        - Your height is: \(height)
        - Current weight: \(currentWeight) lbs
        - Goal weight: \(goalWeight) lbs

        I'll use this information to provide personalized advice. Feel free to ask me any questions about:
        - Exercise recommendations
        - Nutrition advice
        - Weight management
        - General health tips

        What would you like to know?
        """
        
        addMessage(welcomeMessage, isFromUser: false)
    }
    
    private func addUserDataToPrompt() -> String {
        guard let data = userData else { return "" }
        
        var prompt = """
        User Profile Data:
        - Name: \(data["userName"] as? String ?? "Unknown")
        - Height: \(data["height"] as? String ?? "Unknown")
        - Current Weight: \(data["currentWeight"] as? Int ?? 0) lbs
        - Goal Weight: \(data["goalWeight"] as? Int ?? 0) lbs
        - Activity Level: \(data["activityLevel"] as? String ?? "Unknown")
        - Sex: \(data["sex"] as? String ?? "Unknown")
        """
        
        // Add current calories data
        if let caloriesData = caloriesData {
            let dailyCalories = caloriesData["dailyCalories"] as? Double ?? 0
            let targetCalories = caloriesData["targetCalories"] as? Int ?? 0
            
            prompt += """
            
            Today's Nutrition Data:
            - Daily Calorie Intake: \(Int(dailyCalories)) calories
            - Target Daily Calories: \(targetCalories) calories
            """
        }
        
        // Add historical calories data
        if !historicalCaloriesData.isEmpty {
            prompt += "\n\nCalorie History (Last 30 Days):"
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d"
            
            // Show last 7 days of data
            for data in historicalCaloriesData.prefix(7) {
                if let date = (data["date"] as? Timestamp)?.dateValue(),
                   let calories = data["dailyCalories"] as? Double {
                    prompt += "\n- \(dateFormatter.string(from: date)): \(Int(calories)) calories"
                }
            }
        }
        
        // Add recent meals
        if !recentMeals.isEmpty {
            prompt += "\n\nRecent Meals (Last 30 Days):"
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d, HH:mm"
            
            for (index, meal) in recentMeals.prefix(10).enumerated() {
                let name = meal["name"] as? String ?? "Unknown"
                let calories = meal["calories"] as? Int ?? 0
                let date = (meal["date"] as? Timestamp)?.dateValue() ?? Date()
                
                prompt += "\n\(index + 1). \(name) (\(calories) calories) - \(dateFormatter.string(from: date))"
            }
        }
        
        prompt += "\n\nPlease consider this information when providing advice. You can access data from the last 30 days."
        return prompt
    }
    
    private func setupTableView() {
        chatbotView.chatTableView.delegate = self
        chatbotView.chatTableView.dataSource = self
        chatbotView.chatTableView.register(MessageCell.self, forCellReuseIdentifier: "MessageCell")
    }
    
    private func setupActions() {
        chatbotView.sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        chatbotView.messageTextField.delegate = self
    }
    
    private func setupKeyboardHandling() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func sendMessage() {
        guard let message = chatbotView.messageTextField.text, !message.isEmpty else { return }
        
        // Add user message
        addMessage(message, isFromUser: true)
        
        // Add user data to conversation
        let userDataPrompt = addUserDataToPrompt()
        
        // Add to conversation history
        conversationHistory.append(["role": "system", "content": userDataPrompt])
        conversationHistory.append(["role": "user", "content": message])
        
        // Clear text field
        chatbotView.messageTextField.text = ""
        
        // Send to API
        sendToGrokAPI()
    }
    
    private func addMessage(_ content: String, isFromUser: Bool) {
        let message = Message(content: cleanMarkdown(content), isFromUser: isFromUser, timestamp: Date())
        messages.append(message)
        
        DispatchQueue.main.async { [weak self] in
            self?.chatbotView.chatTableView.reloadData()
            // Scroll to bottom
            if let lastRow = self?.messages.count, lastRow > 0 {
                let indexPath = IndexPath(row: lastRow - 1, section: 0)
                self?.chatbotView.chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
    }
    
    private func cleanMarkdown(_ text: String) -> String {
        var cleanText = text
        
        // Remove Markdown headers (###)
        cleanText = cleanText.replacingOccurrences(of: "#+ ", with: "", options: .regularExpression)
        
        // Remove bold markers (**)
        cleanText = cleanText.replacingOccurrences(of: "\\*\\*(.+?)\\*\\*", with: "$1", options: .regularExpression)
        
        // Remove any other Markdown syntax if needed
        // cleanText = cleanText.replacingOccurrences(of: "other_pattern", with: "replacement")
        
        return cleanText
    }
    
    private func scrollToBottom() {
        let lastRow = chatbotView.chatTableView.numberOfRows(inSection: 0) - 1
        if lastRow >= 0 {
            let indexPath = IndexPath(row: lastRow, section: 0)
            chatbotView.chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    private func sendToGrokAPI() {
        guard let url = URL(string: apiUrl) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let requestBody: [String: Any] = [
            "messages": conversationHistory,
            "model": "grok-beta",
            "temperature": 0.7,
            "stream": true
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)
        
        // Create placeholder for bot response
        var currentResponse = ""
        addMessage("", isFromUser: false)
        
        // Make the API call
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.updateLastMessage("Error: \(error.localizedDescription)")
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.updateLastMessage("Error: No data received")
                }
                return
            }
            
            // Handle streaming response
            let lines = String(data: data, encoding: .utf8)?.components(separatedBy: "\n") ?? []
            for line in lines {
                if line.hasPrefix("data: ") {
                    let data = line.dropFirst(6)
                    if data == "[DONE]" { continue }
                    
                    if let jsonData = data.data(using: .utf8),
                       let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
                       let choices = json["choices"] as? [[String: Any]],
                       let delta = choices.first?["delta"] as? [String: Any],
                       let content = delta["content"] as? String {
                        
                        currentResponse += content
                        DispatchQueue.main.async {
                            self.updateLastMessage(currentResponse)
                        }
                    }
                }
            }
            
            // Add complete response to conversation history
            if !currentResponse.isEmpty {
                self.conversationHistory.append([
                    "role": "assistant",
                    "content": currentResponse
                ])
            }
        }
        task.resume()
    }
    
    private func updateLastMessage(_ content: String) {
        guard !messages.isEmpty else { return }
        messages[messages.count - 1] = Message(content: cleanMarkdown(content), isFromUser: false, timestamp: Date())
        chatbotView.chatTableView.reloadData()
        scrollToBottom()
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let inset = keyboardFrame.height - view.safeAreaInsets.bottom
            chatbotView.chatTableView.contentInset.bottom = inset
            chatbotView.chatTableView.scrollIndicatorInsets.bottom = inset
            scrollToBottom()
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        chatbotView.chatTableView.contentInset.bottom = 0
        chatbotView.chatTableView.scrollIndicatorInsets.bottom = 0
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension ChatbotViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageCell
        let message = messages[indexPath.row]
        cell.configure(with: message)
        return cell
    }
}

// MARK: - UITextFieldDelegate
extension ChatbotViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendMessage()
        return true
    }
}
