//
//  ProfileViewController.swift
//  5520_IOS_Group44
//
//  Created by Ninghui Cai on 11/21/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ProfileViewController: UIViewController {

    private let profileView = ProfileView()
    private let db = Firestore.firestore()
    private var currentUser: FirebaseAuth.User?
    private var handleAuth: AuthStateDidChangeListenerHandle?

    // MARK: - UI Elements for Login/Register
    private let textFieldName: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Name"
        tf.borderStyle = .roundedRect
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.keyboardType = .emailAddress
        tf.borderStyle = .roundedRect
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.textContentType = .password
        tf.isSecureTextEntry = true
        tf.borderStyle = .roundedRect
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private let loginButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Login", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let registerButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Register", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let loginContainer: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .fill
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let buttonContainer: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.spacing = 20
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // Activity Indicator (Progress Spinner)
    let childProgressView = ProgressSpinnerViewController()

    override func loadView() {
        view = profileView
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 添加Auth状态监听器
        handleAuth = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            guard let self = self else { return }
            self.currentUser = user
            self.updateUIForUserState()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 移除监听器
        if let handle = handleAuth {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupActions()
        setupLoginUI()
    }

    // MARK: - Setup
    private func setupNavigation() {
        title = "Profile"
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    private func setupActions() {
        let items: [(view: ProfileItemView, selector: Selector)] = [
            (profileView.userNameItem, #selector(editUserName)),
            (profileView.currentWeightItem, #selector(editCurrentWeight)),
            (profileView.goalWeightItem, #selector(editGoalWeight)),
            (profileView.heightItem, #selector(editHeight)),
            (profileView.sexItem, #selector(editSex)),
            (profileView.birthDateItem, #selector(editBirthDate)),
            (profileView.activityLevelItem, #selector(editActivityLevel))
        ]
        
        items.forEach { item, selector in
            let tap = UITapGestureRecognizer(target: self, action: selector)
            item.isUserInteractionEnabled = true
            item.addGestureRecognizer(tap)
        }
    }

    private func setupLoginUI() {
        view.addSubview(loginContainer)
        
        loginContainer.addArrangedSubview(textFieldName)
        loginContainer.addArrangedSubview(emailTextField)
        loginContainer.addArrangedSubview(passwordTextField)
        
        buttonContainer.addArrangedSubview(loginButton)
        buttonContainer.addArrangedSubview(registerButton)
        
        loginContainer.addArrangedSubview(buttonContainer)

        NSLayoutConstraint.activate([
            loginContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            loginContainer.widthAnchor.constraint(equalToConstant: 300)
        ])
        
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)
    }

    // MARK: - Auth UI Updates
    private func updateUIForUserState() {
        if let _ = currentUser {
            // 用户已登录
            loadUserData()
            setupRightBarButton(isLoggedin: true)
            loginContainer.isHidden = true
        } else {
            // 用户未登录
            clearUserDataOnUI()
            setupRightBarButton(isLoggedin: false)
            loginContainer.isHidden = false
        }
    }

    private func setupRightBarButton(isLoggedin: Bool) {
        if isLoggedin {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logoutTapped))
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }

    @objc private func loginTapped() {
        guard let email = emailTextField.text, !email.isEmpty,
              let pass = passwordTextField.text, !pass.isEmpty else {
            return
        }
        showActivityIndicator()
        Auth.auth().signIn(withEmail: email, password: pass) { [weak self] result, error in
            self?.hideActivityIndicator()
            if let error = error {
                print("Login error: \(error)")
                return
            }
            // 登录成功，状态监听器会更新UI
        }
    }

    @objc private func registerTapped() {
        registerNewAccount()
    }

    // MARK: - Register Logic (整合自你的RegisterViewController示例)
    func registerNewAccount(){
        showActivityIndicator()
        
        guard let name = textFieldName.text, !name.isEmpty,
              let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            hideActivityIndicator()
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                self?.hideActivityIndicator()
                print("Error creating user: \(error)")
                return
            }
            // 用户创建成功
            self?.setNameOfTheUserInFirebaseAuth(name: name)
        }
    }

    func setNameOfTheUserInFirebaseAuth(name: String){
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = name
        changeRequest?.commitChanges(completion: { [weak self] (error) in
            if let error = error {
                print("Error setting display name: \(error)")
                self?.hideActivityIndicator()
                return
            }
            // 名字设置成功后初始化用户数据
            if let userId = Auth.auth().currentUser?.uid {
                self?.initializeUserData(for: userId)
            } else {
                self?.hideActivityIndicator()
            }
        })
    }

    func initializeUserData(for userId: String) {
        let userData: [String: Any] = [
            "userName": textFieldName.text ?? "New User",
            "currentWeight": 0,
            "goalWeight": 0,
            "height": "Not set",
            "sex": "Not set",
            "birthDate": "Not set",
            "activityLevel": "Not set",
            "lastUpdated": FieldValue.serverTimestamp()
        ]
        
        db.collection("users").document(userId).setData(userData) { [weak self] error in
            self?.hideActivityIndicator()
            if let error = error {
                print("Error initializing user data: \(error)")
            } else {
                print("User data initialized successfully")
            }
        }
    }

    @objc private func logoutTapped() {
        do {
            try Auth.auth().signOut()
            // 登出后状态监听器会更新界面
        } catch {
            print("Error signing out: \(error)")
        }
    }

    private func clearUserDataOnUI() {
        profileView.userNameItem.valueLabel.text = "Not set"
        profileView.currentWeightItem.valueLabel.text = "0 lbs"
        profileView.goalWeightItem.valueLabel.text = "0 lbs"
        profileView.heightItem.valueLabel.text = "Not set"
        profileView.sexItem.valueLabel.text = "Not set"
        profileView.birthDateItem.valueLabel.text = "Not set"
        profileView.activityLevelItem.valueLabel.text = "Not set"
    }

    // MARK: - Firebase Data Management
    private func loadUserData() {
        guard let userId = currentUser?.uid else { return }
        
        db.collection("users").document(userId).getDocument { [weak self] snapshot, error in
            if let error = error {
                print("Error loading user data: \(error)")
                return
            }
            
            guard let data = snapshot?.data() else {
                print("No user data found")
                return
            }
            
            DispatchQueue.main.async {
                self?.profileView.userNameItem.valueLabel.text = data["userName"] as? String ?? "Not set"
                self?.profileView.currentWeightItem.valueLabel.text = "\(data["currentWeight"] as? Int ?? 0) lbs"
                self?.profileView.goalWeightItem.valueLabel.text = "\(data["goalWeight"] as? Int ?? 0) lbs"
                self?.profileView.heightItem.valueLabel.text = data["height"] as? String ?? "Not set"
                self?.profileView.sexItem.valueLabel.text = data["sex"] as? String ?? "Not set"
                self?.profileView.birthDateItem.valueLabel.text = data["birthDate"] as? String ?? "Not set"
                self?.profileView.activityLevelItem.valueLabel.text = data["activityLevel"] as? String ?? "Not set"
            }
        }
    }

    private func saveUserData() {
        guard let userId = currentUser?.uid else { return }
        
        let userData: [String: Any] = [
            "userName": profileView.userNameItem.valueLabel.text ?? "",
            "currentWeight": Int(profileView.currentWeightItem.valueLabel.text?.components(separatedBy: " ").first ?? "0") ?? 0,
            "goalWeight": Int(profileView.goalWeightItem.valueLabel.text?.components(separatedBy: " ").first ?? "0") ?? 0,
            "height": profileView.heightItem.valueLabel.text ?? "",
            "sex": profileView.sexItem.valueLabel.text ?? "",
            "birthDate": profileView.birthDateItem.valueLabel.text ?? "",
            "activityLevel": profileView.activityLevelItem.valueLabel.text ?? "",
            "lastUpdated": FieldValue.serverTimestamp()
        ]
        
        db.collection("users").document(userId).setData(userData, merge: true) { error in
            if let error = error {
                print("Error saving user data: \(error)")
            } else {
                print("User data saved successfully")
            }
        }
    }

    // MARK: - Edit Methods
    @objc private func editUserName() {
        let currentValue = profileView.userNameItem.valueLabel.text ?? ""
        showTextFieldAlert(title: "Edit Name", message: "Enter your name", currentValue: currentValue) { [weak self] newValue in
            self?.profileView.userNameItem.valueLabel.text = newValue
            self?.saveUserData()
        }
    }
    
    @objc private func editCurrentWeight() {
        showNumberPickerAlert(title: "Current Weight", unit: "lbs", range: 80...400) { [weak self] value in
            self?.profileView.currentWeightItem.valueLabel.text = "\(value) lbs"
            self?.saveUserData()
        }
    }
    
    @objc private func editGoalWeight() {
        showNumberPickerAlert(title: "Goal Weight", unit: "lbs", range: 80...400) { [weak self] value in
            self?.profileView.goalWeightItem.valueLabel.text = "\(value) lbs"
            self?.saveUserData()
        }
    }
    
    @objc private func editHeight() {
        showHeightPicker()
    }
    
    @objc private func editSex() {
        showSexPicker()
    }
    
    @objc private func editBirthDate() {
        showDatePicker()
    }
    
    @objc private func editActivityLevel() {
        let alert = UIAlertController(title: "Activity Level", message: nil, preferredStyle: .actionSheet)
        
        ["Sedentary", "Lightly active", "Moderately active", "Very active", "Extra active"].forEach { level in
            let action = UIAlertAction(title: level, style: .default) { [weak self] _ in
                self?.profileView.activityLevelItem.valueLabel.text = level
                self?.saveUserData()
            }
            alert.addAction(action)
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    // MARK: - Helper Methods
    private func showTextFieldAlert(title: String, message: String, currentValue: String, completion: @escaping (String) -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = currentValue
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default) { _ in
            if let text = alert.textFields?.first?.text, !text.isEmpty {
                completion(text)
            }
        })
        
        present(alert, animated: true)
    }
    
    private func showNumberPickerAlert(title: String, unit: String, range: ClosedRange<Int>, completion: @escaping (Int) -> Void) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        let pickerView = UIPickerView()
        pickerView.tag = 1 // Weight
        pickerView.delegate = self
        pickerView.dataSource = self
        
        let currentValueText = profileView.currentWeightItem.valueLabel.text?.components(separatedBy: " ").first ?? "0"
        if let currentValue = Int(currentValueText), range.contains(currentValue) {
            pickerView.selectRow(currentValue - range.lowerBound, inComponent: 0, animated: false)
        }
        
        let contentVC = UIViewController()
        contentVC.view = pickerView
        alert.setValue(contentVC, forKey: "contentViewController")

        alert.addAction(UIAlertAction(title: "Done", style: .default) { _ in
            let selectedRow = pickerView.selectedRow(inComponent: 0)
            completion(selectedRow + range.lowerBound)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        alert.view.heightAnchor.constraint(equalToConstant: 300).isActive = true
        present(alert, animated: true)
    }

    private func showHeightPicker() {
        let alert = UIAlertController(title: "Height", message: nil, preferredStyle: .actionSheet)
        let pickerView = UIPickerView()
        pickerView.tag = 0 // Height
        pickerView.delegate = self
        pickerView.dataSource = self
        
        let contentVC = UIViewController()
        contentVC.view = pickerView
        alert.setValue(contentVC, forKey: "contentViewController")

        alert.addAction(UIAlertAction(title: "Done", style: .default) { [weak self] _ in
            let feet = pickerView.selectedRow(inComponent: 0) + 4
            let inches = pickerView.selectedRow(inComponent: 1)
            self?.profileView.heightItem.valueLabel.text = "\(feet) ft \(inches) in"
            self?.saveUserData()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        alert.view.heightAnchor.constraint(equalToConstant: 300).isActive = true
        present(alert, animated: true)
    }

    private func showSexPicker() {
        let alert = UIAlertController(title: "Select Biological Sex", message: nil, preferredStyle: .actionSheet)

        ["Male", "Female"].forEach { sex in
            let action = UIAlertAction(title: sex, style: .default) { [weak self] _ in
                self?.profileView.sexItem.valueLabel.text = sex
                self?.saveUserData()
            }
            alert.addAction(action)
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    private func showDatePicker() {
        let alert = UIAlertController(title: "Date of Birth", message: nil, preferredStyle: .actionSheet)
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        
        let contentVC = UIViewController()
        contentVC.view = datePicker
        alert.setValue(contentVC, forKey: "contentViewController")

        alert.addAction(UIAlertAction(title: "Done", style: .default) { [weak self] _ in
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            self?.profileView.birthDateItem.valueLabel.text = formatter.string(from: datePicker.date)
            self?.saveUserData()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        alert.view.heightAnchor.constraint(equalToConstant: 300).isActive = true
        present(alert, animated: true)
    }
}

// MARK: - UIPickerViewDelegate & DataSource
extension ProfileViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerView.tag == 1 { // Weight
            return 1
        }
        return 2 // Height
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1 { // Weight
            return 321 // 80 - 400
        }
        // Height: Feet:4-7 (4 rows), Inches:0-11 (12 rows)
        return component == 0 ? 4 : 12
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1 { // Weight
            return "\(row + 80) lbs"
        }
        // Height
        if component == 0 {
            return "\(row + 4) ft"
        } else {
            return "\(row) in"
        }
    }
}

// MARK: - ProgressSpinnerDelegate
extension ProfileViewController {
    func showActivityIndicator(){
        addChild(childProgressView)
        view.addSubview(childProgressView.view)
        childProgressView.didMove(toParent: self)
    }
    
    func hideActivityIndicator(){
        childProgressView.willMove(toParent: nil)
        childProgressView.view.removeFromSuperview()
        childProgressView.removeFromParent()
    }
}
