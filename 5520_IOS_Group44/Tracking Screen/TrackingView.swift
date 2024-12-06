class TrackingView: UIView {
    
    // MARK: - Properties
    var dateLabel: UILabel!
    var calorieRemainingLabel: UILabel!
    var targetCalorieLabel: UILabel!  // 用于显示目标卡路里
    var currentCalorieLabel: UILabel!  // 用于显示当前卡路里
    var progressView: UIProgressView!  // 进度条
    var editTargetButton: UIButton!  // 编辑目标按钮
    var addMealButton: UIButton!  // 添加餐食按钮
    var addExerciseButton: UIButton!  // 添加运动按钮
    var containerView: UIView!  // 白色背景容器
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .systemGray6
        setupViews()
        initConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        // 日期标签
        dateLabel = UILabel()
        dateLabel.font = .systemFont(ofSize: 28, weight: .medium)
        dateLabel.textAlignment = .center
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(dateLabel)
        
        // 白色容器视图
        containerView = UIView()
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 20
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 6
        containerView.layer.shadowOpacity = 0.1
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)
        
        // Calorie Remaining 标签
        calorieRemainingLabel = UILabel()
        calorieRemainingLabel.text = "Calorie Remaining"
        calorieRemainingLabel.font = .systemFont(ofSize: 32)
        calorieRemainingLabel.textAlignment = .center
        calorieRemainingLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(calorieRemainingLabel)
        
        // 目标卡路里标签
        targetCalorieLabel = UILabel()
        targetCalorieLabel.font = .systemFont(ofSize: 36, weight: .bold)
        targetCalorieLabel.textAlignment = .right
        targetCalorieLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(targetCalorieLabel)
        
        // 进度条
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.progressTintColor = UIColor(red: 0.92, green: 0.4, blue: 0.4, alpha: 1)
        progressView.trackTintColor = .systemGray5
        progressView.progress = 0.0
        progressView.transform = CGAffineTransform(scaleX: 1, y: 4)
        progressView.layer.cornerRadius = 2
        progressView.clipsToBounds = true
        progressView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(progressView)
        
        // 当前卡路里标签
        currentCalorieLabel = UILabel()
        currentCalorieLabel.font = .systemFont(ofSize: 36, weight: .bold)
        currentCalorieLabel.textAlignment = .left
        currentCalorieLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(currentCalorieLabel)
        
        // 编辑目标按钮
        editTargetButton = UIButton(type: .system)
        editTargetButton.setImage(UIImage(systemName: "pencil"), for: .normal)
        editTargetButton.tintColor = .systemOrange
        editTargetButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(editTargetButton)
        
        // 添加餐食按钮
        addMealButton = UIButton(type: .system)
        addMealButton.setTitle("+ Add meal", for: .normal)
        addMealButton.titleLabel?.font = .systemFont(ofSize: 20)
        addMealButton.backgroundColor = .white
        addMealButton.layer.cornerRadius = 15
        addMealButton.layer.borderWidth = 1
        addMealButton.layer.borderColor = UIColor.systemGray3.cgColor
        addMealButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(addMealButton)
        
        // 添加运动按钮
        addExerciseButton = UIButton(type: .system)
        addExerciseButton.setTitle("+ Add exercise", for: .normal)
        addExerciseButton.titleLabel?.font = .systemFont(ofSize: 20)
        addExerciseButton.backgroundColor = .white
        addExerciseButton.layer.cornerRadius = 15
        addExerciseButton.layer.borderWidth = 1
        addExerciseButton.layer.borderColor = UIColor.systemGray3.cgColor
        addExerciseButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(addExerciseButton)
    }
    
    private func initConstraints() {
        NSLayoutConstraint.activate([
            // 日期标签约束
            dateLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            dateLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            // 容器视图约束
            containerView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 20),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            // Calorie Remaining 标签约束
            calorieRemainingLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 24),
            calorieRemainingLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            // 目标卡路里标签约束
            targetCalorieLabel.topAnchor.constraint(equalTo: calorieRemainingLabel.bottomAnchor, constant: 40),
            targetCalorieLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            
            // 进度条约束
            progressView.topAnchor.constraint(equalTo: targetCalorieLabel.bottomAnchor, constant: 24),
            progressView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            progressView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            
            // 当前卡路里标签约束
            currentCalorieLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 16),
            currentCalorieLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            
            // 编辑按钮约束
            editTargetButton.centerYAnchor.constraint(equalTo: currentCalorieLabel.centerY),
            editTargetButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            
            // 容器底部约束
            containerView.bottomAnchor.constraint(equalTo: currentCalorieLabel.bottomAnchor, constant: 24),
            
            // 添加餐食按钮约束
            addMealButton.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 24),
            addMealButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            addMealButton.trailingAnchor.constraint(equalTo: centerXAnchor, constant: -8),
            addMealButton.heightAnchor.constraint(equalToConstant: 50),
            
            // 添加运动按钮约束
            addExerciseButton.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 24),
            addExerciseButton.leadingAnchor.constraint(equalTo: centerXAnchor, constant: 8),
            addExerciseButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            addExerciseButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }
} 