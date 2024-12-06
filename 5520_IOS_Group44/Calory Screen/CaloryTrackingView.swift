import UIKit

class CaloryTrackingView: UIView {
    
    // MARK: - Properties
    var leftArrowButton: UIButton!
    var rightArrowButton: UIButton!
    var dateLabel: UILabel!
    var calorieRemainingLabel: UILabel!
    var targetCalorieLabel: UILabel!
    var currentCalorieLabel: UILabel!
    var progressView: UIProgressView!
    var editTargetButton: UIButton!
    var addMealButton: UIButton!
    var containerView: UIView!
    var appleImageView: UIImageView!
    var dailyCaloriesLabel: UILabel!
    var foodTableView: UITableView!
    var mealTableView: UITableView!
    var scrollView: UIScrollView!
    var contentView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .systemBackground
        setupScrollView()
        setupViews()
        setupFoodTableView()
        setupMealTableView()
        initConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupScrollView() {
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)
        
        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
    }
    
    private func setupViews() {
        // Left arrow button
        leftArrowButton = UIButton(type: .system)
        leftArrowButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        leftArrowButton.tintColor = .black
        leftArrowButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(leftArrowButton)
        
        // Right arrow button
        rightArrowButton = UIButton(type: .system)
        rightArrowButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        rightArrowButton.tintColor = .black
        rightArrowButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(rightArrowButton)
        
        // Date label
        dateLabel = UILabel()
        dateLabel.font = .systemFont(ofSize: 24, weight: .bold)
        dateLabel.textAlignment = .center
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(dateLabel)
        
        // White container view
        containerView = UIView()
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 20
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 6
        containerView.layer.shadowOpacity = 0.1
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)
        
        // Calorie Remaining label
        calorieRemainingLabel = UILabel()
        calorieRemainingLabel.text = "Calories Remaining"
        calorieRemainingLabel.font = .systemFont(ofSize: 20, weight: .bold)
        calorieRemainingLabel.textAlignment = .center
        calorieRemainingLabel.textColor = UIColor(red: 0.8, green: 0.4, blue: 0.8, alpha: 1.0)
        calorieRemainingLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(calorieRemainingLabel)
        
        // Apple icon
        appleImageView = UIImageView(image: UIImage(systemName: "applelogo"))
        appleImageView.tintColor = .systemPink
        appleImageView.contentMode = .scaleAspectFit
        appleImageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(appleImageView)
        
        // Target calorie label
        targetCalorieLabel = UILabel()
        targetCalorieLabel.text = "1,987"
        targetCalorieLabel.font = .systemFont(ofSize: 28, weight: .bold)
        targetCalorieLabel.textAlignment = .right
        targetCalorieLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(targetCalorieLabel)
        
        // Edit target button
        editTargetButton = UIButton(type: .system)
        editTargetButton.setImage(UIImage(systemName: "pencil"), for: .normal)
        editTargetButton.tintColor = .systemOrange
        editTargetButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(editTargetButton)
        
        // Progress bar
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.transform = CGAffineTransform(scaleX: 1, y: 4)
        progressView.layer.cornerRadius = 4
        progressView.clipsToBounds = true
        progressView.progressTintColor = UIColor(red: 0.8, green: 0.4, blue: 0.8, alpha: 1.0)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(progressView)
        
        // Current calorie label
        currentCalorieLabel = UILabel()
        currentCalorieLabel.text = "0"
        currentCalorieLabel.font = .systemFont(ofSize: 26, weight: .bold)
        currentCalorieLabel.textAlignment = .left
        currentCalorieLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(currentCalorieLabel)
        
        // Daily Calories Label
        dailyCaloriesLabel = UILabel()
        dailyCaloriesLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        dailyCaloriesLabel.textAlignment = .center
        dailyCaloriesLabel.textColor = .systemPink
        dailyCaloriesLabel.text = "Daily: 0"
        dailyCaloriesLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(dailyCaloriesLabel)
        
        // Add meal button
        addMealButton = UIButton(type: .system)
        let mealTitle = NSMutableAttributedString(string: "🍔 + Add meal")
        let mealCrownAttachment = NSTextAttachment()
        mealCrownAttachment.image = UIImage(systemName: "crown.fill")?.withTintColor(.systemYellow)
        mealTitle.append(NSAttributedString(attachment: mealCrownAttachment))
        addMealButton.setAttributedTitle(mealTitle, for: .normal)
        addMealButton.titleLabel?.font = .systemFont(ofSize: 18)
        addMealButton.backgroundColor = .white
        addMealButton.layer.cornerRadius = 10
        addMealButton.layer.borderWidth = 1
        addMealButton.layer.borderColor = UIColor.systemGray3.cgColor
        addMealButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(addMealButton)
    }
    
    private func setupFoodTableView() {
        foodTableView = UITableView()
        foodTableView.register(UITableViewCell.self, forCellReuseIdentifier: "FoodCell")
        foodTableView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(foodTableView)
    }
    
    private func setupMealTableView() {
        mealTableView = UITableView()
        mealTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MealCell")
        mealTableView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(mealTableView)
    }
    
    private func initConstraints() {
        NSLayoutConstraint.activate([
            // ScrollView constraints
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // ContentView constraints
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Left arrow button constraints
            leftArrowButton.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor),
            leftArrowButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            // Right arrow button constraints
            rightArrowButton.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor),
            rightArrowButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Date label constraints
            dateLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 32),
            dateLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dateLabel.leadingAnchor.constraint(equalTo: leftArrowButton.trailingAnchor, constant: 16),
            dateLabel.trailingAnchor.constraint(equalTo: rightArrowButton.leadingAnchor, constant: -16),
            dateLabel.heightAnchor.constraint(equalToConstant: 40),
            
            // Container view constraints
            containerView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 32),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Calorie Remaining label constraints
            calorieRemainingLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 24),
            calorieRemainingLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            // Apple icon constraints
            appleImageView.centerYAnchor.constraint(equalTo: targetCalorieLabel.centerYAnchor),
            appleImageView.trailingAnchor.constraint(equalTo: targetCalorieLabel.leadingAnchor, constant: -8),
            appleImageView.widthAnchor.constraint(equalToConstant: 24),
            appleImageView.heightAnchor.constraint(equalToConstant: 24),
            
            // Target calorie label constraints
            targetCalorieLabel.topAnchor.constraint(equalTo: calorieRemainingLabel.bottomAnchor, constant: 40),
            targetCalorieLabel.trailingAnchor.constraint(equalTo: editTargetButton.leadingAnchor, constant: -8),
            
            // Edit target button constraints
            editTargetButton.centerYAnchor.constraint(equalTo: targetCalorieLabel.centerYAnchor),
            editTargetButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            
            // Progress bar constraints
            progressView.topAnchor.constraint(equalTo: targetCalorieLabel.bottomAnchor, constant: 24),
            progressView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            progressView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            
            // Current calorie label constraints
            currentCalorieLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 16),
            currentCalorieLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            
            // Container bottom constraints
            containerView.bottomAnchor.constraint(equalTo: currentCalorieLabel.bottomAnchor, constant: 24),
            
            // Daily Calories Label constraints
            dailyCaloriesLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 16),
            dailyCaloriesLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            dailyCaloriesLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            dailyCaloriesLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            // Add meal button constraints
            addMealButton.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 24),
            addMealButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            addMealButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Meal TableView constraints
            mealTableView.topAnchor.constraint(equalTo: addMealButton.bottomAnchor, constant: 20),
            mealTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            mealTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            mealTableView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.3),
            
            // Food TableView constraints
            foodTableView.topAnchor.constraint(equalTo: mealTableView.bottomAnchor, constant: 20),
            foodTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            foodTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            foodTableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}
