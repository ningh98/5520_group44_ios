//
//  FastingView.swift
//  5520_IOS_Group44
//
//  Created by Ninghui Cai on 11/21/24.
//

import UIKit

class CircularProgressView: UIView {
    private var progressLayer = CAShapeLayer()
    private var trackLayer = CAShapeLayer()
    private var gradientLayer = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createCircularPath()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        createCircularPath()
    }
    
    private func createCircularPath() {
        self.backgroundColor = .clear
        let circularPath = UIBezierPath(arcCenter: CGPoint(x: frame.size.width/2, y: frame.size.height/2),
                                      radius: (frame.size.width - 40)/2,
                                      startAngle: -(.pi / 2),
                                      endAngle: 2 * .pi - (.pi / 2),
                                      clockwise: true)
        
        trackLayer.path = circularPath.cgPath
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = UIColor.systemGray6.cgColor
        trackLayer.lineWidth = 20
        trackLayer.strokeEnd = 1.0
        layer.addSublayer(trackLayer)
        
        progressLayer.path = circularPath.cgPath
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = UIColor.red.cgColor
        progressLayer.lineWidth = 20
        progressLayer.strokeEnd = 0.0
        progressLayer.lineCap = .round
        
        gradientLayer.colors = [UIColor.systemPink.cgColor, UIColor.systemPurple.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = bounds
        gradientLayer.mask = progressLayer
        
        layer.addSublayer(gradientLayer)
    }
    
    func setProgress(to progressConstant: Double) {
        progressLayer.strokeEnd = progressConstant
    }
}

class TimeSelectionCard: UIView {
    var titleLabel: UILabel!
    var timeLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 12
        
        titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = .secondaryLabel
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        
        timeLabel = UILabel()
        timeLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        timeLabel.textColor = .label
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(timeLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 80),
            
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            timeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            timeLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            timeLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }
    
    convenience init(title: String) {
        self.init(frame: .zero)
        titleLabel.text = title
        timeLabel.text = "Not set"
    }
}

class FastingView: UIView {
    var progressView: CircularProgressView!
    var fastingForLabel: UILabel!
    var timerLabel: UILabel!
    var remainingLabel: UILabel!
    var actionButton: GradientButton!
    var startTimeCard: TimeSelectionCard!
    var goalTimeCard: TimeSelectionCard!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .systemBackground
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        progressView = CircularProgressView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
        progressView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(progressView)
        
        fastingForLabel = UILabel()
        fastingForLabel.text = "Fasting for"
        fastingForLabel.textColor = .secondaryLabel
        fastingForLabel.font = .systemFont(ofSize: 18)
        fastingForLabel.textAlignment = .center
        fastingForLabel.translatesAutoresizingMaskIntoConstraints = false
        progressView.addSubview(fastingForLabel)
        
        timerLabel = UILabel()
        timerLabel.text = "00:00"
        timerLabel.font = .monospacedDigitSystemFont(ofSize: 44, weight: .medium)
        timerLabel.textAlignment = .center
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        progressView.addSubview(timerLabel)
        
        remainingLabel = UILabel()
        remainingLabel.text = "00:00 left"
        remainingLabel.textColor = .secondaryLabel
        remainingLabel.font = .systemFont(ofSize: 16)
        remainingLabel.textAlignment = .center
        remainingLabel.translatesAutoresizingMaskIntoConstraints = false
        progressView.addSubview(remainingLabel)
        
        actionButton = GradientButton()
        actionButton.setTitle("Start fasting", for: .normal)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(actionButton)
        
        startTimeCard = TimeSelectionCard(title: "START")
        startTimeCard.translatesAutoresizingMaskIntoConstraints = false
        addSubview(startTimeCard)
        
        goalTimeCard = TimeSelectionCard(title: "GOAL")
        goalTimeCard.translatesAutoresizingMaskIntoConstraints = false
        addSubview(goalTimeCard)
        
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            progressView.centerXAnchor.constraint(equalTo: centerXAnchor),
            progressView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 40),
            progressView.widthAnchor.constraint(equalToConstant: 300),
            progressView.heightAnchor.constraint(equalToConstant: 300),
            
            fastingForLabel.centerXAnchor.constraint(equalTo: progressView.centerXAnchor),
            fastingForLabel.bottomAnchor.constraint(equalTo: timerLabel.topAnchor, constant: -8),
            
            timerLabel.centerXAnchor.constraint(equalTo: progressView.centerXAnchor),
            timerLabel.centerYAnchor.constraint(equalTo: progressView.centerYAnchor),
            
            remainingLabel.centerXAnchor.constraint(equalTo: progressView.centerXAnchor),
            remainingLabel.topAnchor.constraint(equalTo: timerLabel.bottomAnchor, constant: 8),
            
            actionButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            actionButton.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 40),
            actionButton.widthAnchor.constraint(equalToConstant: 200),
            actionButton.heightAnchor.constraint(equalToConstant: 50),
            
            startTimeCard.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            startTimeCard.topAnchor.constraint(equalTo: actionButton.bottomAnchor, constant: 40),
            startTimeCard.widthAnchor.constraint(equalToConstant: (UIScreen.main.bounds.width - 60) / 2),
            
            goalTimeCard.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            goalTimeCard.topAnchor.constraint(equalTo: startTimeCard.topAnchor),
            goalTimeCard.widthAnchor.constraint(equalTo: startTimeCard.widthAnchor)
        ])
    }
    
    func updateForFastingState(isFasting: Bool) {
        actionButton.setTitle(isFasting ? "End fasting" : "Start fasting", for: .normal)
    }
}

class StartFastingView: UIView {
    var titleLabel: UILabel!
    var goalDurationLabel: UILabel!
    var goalDurationValueLabel: UILabel!
    var startTimeLabel: UILabel!
    var startTimeValueLabel: UILabel!
    var goalTimeLabel: UILabel!
    var goalTimeValueLabel: UILabel!
    var startButton: GradientButton!
    var cancelButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        layer.cornerRadius = 20
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        titleLabel = UILabel()
        titleLabel.text = "Ready to start this fast"
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = UIColor(red: 0.91, green: 0.41, blue: 0.54, alpha: 1.0) // Pink color
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        
        goalDurationLabel = UILabel()
        goalDurationLabel.text = "Goal duration"
        goalDurationLabel.font = .systemFont(ofSize: 20, weight: .bold)
        goalDurationLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(goalDurationLabel)
        
        goalDurationValueLabel = UILabel()
        goalDurationValueLabel.text = "16h"
        goalDurationValueLabel.font = .systemFont(ofSize: 20)
        goalDurationValueLabel.textColor = .systemOrange
        goalDurationValueLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(goalDurationValueLabel)
        
        startTimeLabel = UILabel()
        startTimeLabel.text = "Start time"
        startTimeLabel.font = .systemFont(ofSize: 20, weight: .bold)
        startTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(startTimeLabel)
        
        startTimeValueLabel = UILabel()
        startTimeValueLabel.text = "Today, 23:29"
        startTimeValueLabel.font = .systemFont(ofSize: 20)
        startTimeValueLabel.textColor = .systemOrange
        startTimeValueLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(startTimeValueLabel)
        
        goalTimeLabel = UILabel()
        goalTimeLabel.text = "Goal time"
        goalTimeLabel.font = .systemFont(ofSize: 20, weight: .bold)
        goalTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(goalTimeLabel)
        
        goalTimeValueLabel = UILabel()
        goalTimeValueLabel.text = "Tomorrow, 15:29"
        goalTimeValueLabel.font = .systemFont(ofSize: 20)
        goalTimeValueLabel.textColor = .gray
        goalTimeValueLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(goalTimeValueLabel)
        
        startButton = GradientButton()
        startButton.setTitle("Start", for: .normal)
        startButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        startButton.layer.cornerRadius = 25
        startButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(startButton)
        
        cancelButton = UIButton(type: .system)
        cancelButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        cancelButton.tintColor = .systemPurple
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(cancelButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            cancelButton.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            cancelButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            cancelButton.widthAnchor.constraint(equalToConstant: 30),
            cancelButton.heightAnchor.constraint(equalToConstant: 30),
            
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            goalDurationLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            goalDurationLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            
            goalDurationValueLabel.centerYAnchor.constraint(equalTo: goalDurationLabel.centerYAnchor),
            goalDurationValueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            startTimeLabel.topAnchor.constraint(equalTo: goalDurationLabel.bottomAnchor, constant: 30),
            startTimeLabel.leadingAnchor.constraint(equalTo: goalDurationLabel.leadingAnchor),
            
            startTimeValueLabel.centerYAnchor.constraint(equalTo: startTimeLabel.centerYAnchor),
            startTimeValueLabel.trailingAnchor.constraint(equalTo: goalDurationValueLabel.trailingAnchor),
            
            goalTimeLabel.topAnchor.constraint(equalTo: startTimeLabel.bottomAnchor, constant: 30),
            goalTimeLabel.leadingAnchor.constraint(equalTo: startTimeLabel.leadingAnchor),
            
            goalTimeValueLabel.centerYAnchor.constraint(equalTo: goalTimeLabel.centerYAnchor),
            goalTimeValueLabel.trailingAnchor.constraint(equalTo: startTimeValueLabel.trailingAnchor),
            
            startButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -30),
            startButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            startButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            startButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            startButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}

class GradientButton: UIButton {
    private let gradientLayer = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradient()
        setupButton()
    }
    
    private func setupButton() {
        backgroundColor = .clear
        setTitleColor(.white, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        layer.cornerRadius = 25
        clipsToBounds = true
        isUserInteractionEnabled = true
    }
    
    private func setupGradient() {
        gradientLayer.colors = [
            UIColor(red: 0.91, green: 0.41, blue: 0.54, alpha: 1.0).cgColor, // Pink
            UIColor(red: 0.57, green: 0.35, blue: 0.93, alpha: 1.0).cgColor  // Purple
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = layer.cornerRadius
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let biggerFrame = bounds.insetBy(dx: -10, dy: -10)
        return biggerFrame.contains(point)
    }
}
