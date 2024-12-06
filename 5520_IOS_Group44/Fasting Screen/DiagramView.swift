//
//  DiagramView.swift
//  5520_IOS_Group44
//
//  Created by Lambert on 2024/12/4.
//

import UIKit

struct FastingLog {
    var date: Date
    var dateString: String
    var duration: TimeInterval
}

class DiagramView: UIView {
    var logs: [FastingLog] = []
    
    lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.text = "Fasting Records"
        view.frame = CGRect(x: 10, y: 0, width: UIScreen.main.bounds.size.width-40-20, height: 60)
        view.font = .systemFont(ofSize: 22, weight: .bold)
        return view
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: DiagramViewCell.width(), height: DiagramViewCell.height())
        layout.minimumLineSpacing = 15
        
        let view = UICollectionView(frame: CGRect(x: 10, y: 60, width: UIScreen.main.bounds.size.width-40-20-40, height: DiagramViewCell.height()), collectionViewLayout: layout)
        view.backgroundColor = .clear
        view.register(DiagramViewCell.self, forCellWithReuseIdentifier: "cell")
        view.dataSource = self
        view.delegate = self
        return view
    }()
    
    lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.distribution = .equalSpacing
        view.frame = CGRect(x: UIScreen.main.bounds.size.width-40-40, y: 60, width: 40, height: DiagramViewCell.height()-31)
        for i in 0...6 {
            let label = UILabel()
            label.frame = CGRect(x: 0, y: 0, width: 40, height: 30)
            label.font = .systemFont(ofSize: 13)
            label.textColor = .black
            label.textAlignment = .center
            label.text = String(format: "%zdh", (6-i)*4)
            view.addArrangedSubview(label)
        }
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        addSubview(stackView)
        addSubview(collectionView)
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 0.91, green: 0.41, blue: 0.54, alpha: 1.0).cgColor, // Pink
            UIColor(red: 0.57, green: 0.35, blue: 0.93, alpha: 1.0).cgColor  // Purple
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.frame = titleLabel.bounds
        gradientLayer.mask = titleLabel.layer
        self.layer.addSublayer(gradientLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func refresh(logs: [FastingLog]) {
        self.logs.removeAll()
        self.logs.append(contentsOf: logs)
        collectionView.reloadData()
        collectionView.setNeedsLayout()
        collectionView.layoutIfNeeded()
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
            if self.logs.count > 0 {
                self.collectionView.scrollToItem(at: IndexPath(item: self.logs.count-1, section: 0), at: .right, animated: false)
            }
        }
    }
}

extension DiagramView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return logs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? DiagramViewCell {
            cell.refresh(log: logs[indexPath.item])
            return cell
        }
        return UICollectionViewCell()
    }
}

class DiagramViewCell: UICollectionViewCell {
    private let dateFormatter = DateFormatter()
    lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.frame = CGRect(x: 0, y: DiagramViewCell.height()-21, width: DiagramViewCell.width(), height: 21)
        view.font = .systemFont(ofSize: 10)
        view.textAlignment = .center
        view.textColor = .black
        return view
    }()
    
    lazy var bar: UIView = {
        let view = UIView()
        view.frame = CGRect(x: 5, y: 0, width: DiagramViewCell.width()-10, height: DiagramViewCell.height()-31.0)
        view.backgroundColor = .secondarySystemBackground
        return view
    }()
    
    lazy var barLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.systemPink.cgColor, UIColor.systemPurple.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.frame = bar.bounds
        gradientLayer.mask = maskLayer
        return gradientLayer
    }()
    
    lazy var maskLayer: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor.black.cgColor
        return layer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        dateFormatter.dateFormat = "MM/dd"
        contentView.addSubview(titleLabel)
        contentView.addSubview(bar)
        bar.layer.addSublayer(barLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func refresh(log: FastingLog) {
        titleLabel.text = log.dateString
        let progress = Double(log.duration/86400.0)
        let height = (DiagramViewCell.height()-31.0)*progress
        maskLayer.frame = CGRect(x: 0, y: DiagramViewCell.height()-31.0-height, width: DiagramViewCell.width()-10, height: height)
        print("xxxx-\(log.dateString),dur=\(log.duration),progress=\(progress)")
    }
    
    static func width() -> CGFloat {
        return (UIScreen.main.bounds.size.width-40-20-40-6*15)/7.0
    }
    
    static func height() -> CGFloat {
        return 181.0
    }
}
