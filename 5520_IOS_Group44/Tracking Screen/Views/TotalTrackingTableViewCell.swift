//
//  TotalTrackingTableViewCell.swift
//  5520_IOS_Group44
//
//  Created by Ninghui Cai on 11/21/24.
//

import UIKit

class TotalTrackingTableViewCell: UITableViewCell {
    
    var wrapperCellView: UIView!
    var labelCalories: UILabel!
    var labelProtein: UILabel!
    var labelCarbs: UILabel!
    var labelFat: UILabel!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupWrapperCellView()
        setupLabelCalories()
        setupLabelProtein()
        setupLabelCarbs()
        setupLabelFat()
        
        
        initConstraints()
    }
    
    func setupWrapperCellView(){
        wrapperCellView = UITableViewCell()
                
        //working with the shadows and colors...
        wrapperCellView.backgroundColor = .white
        wrapperCellView.layer.cornerRadius = 6.0
        wrapperCellView.layer.shadowColor = UIColor.gray.cgColor
        wrapperCellView.layer.shadowOffset = .zero
        wrapperCellView.layer.shadowRadius = 4.0
        wrapperCellView.layer.shadowOpacity = 0.4
        wrapperCellView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(wrapperCellView)
    }
    
    func setupLabelCalories(){
        labelCalories = UILabel()
        labelCalories.font = UIFont.systemFont(ofSize: 13)
        labelCalories.translatesAutoresizingMaskIntoConstraints = false
        labelCalories.adjustsFontSizeToFitWidth = true
        labelCalories.minimumScaleFactor = 0.8
        wrapperCellView.addSubview(labelCalories)
    }
    
    func setupLabelProtein(){
        labelProtein = UILabel()
        labelProtein.font = UIFont.systemFont(ofSize: 13)
        labelProtein.translatesAutoresizingMaskIntoConstraints = false
        labelProtein.adjustsFontSizeToFitWidth = true
        labelProtein.minimumScaleFactor = 0.8
        wrapperCellView.addSubview(labelProtein)
    }
    
    func setupLabelCarbs(){
        labelCarbs = UILabel()
        labelCarbs.font = UIFont.systemFont(ofSize: 13)
        labelCarbs.translatesAutoresizingMaskIntoConstraints = false
        labelCarbs.adjustsFontSizeToFitWidth = true
        labelCarbs.minimumScaleFactor = 0.8
        wrapperCellView.addSubview(labelCarbs)
    }
    
    func setupLabelFat(){
        labelFat = UILabel()
        labelFat.font = UIFont.systemFont(ofSize: 13)
        labelFat.translatesAutoresizingMaskIntoConstraints = false
        labelFat.adjustsFontSizeToFitWidth = true
        labelFat.minimumScaleFactor = 0.8
        wrapperCellView.addSubview(labelFat)
    }
    
    
    func initConstraints(){
        NSLayoutConstraint.activate([
            wrapperCellView.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            wrapperCellView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5),
            wrapperCellView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5),
            wrapperCellView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5),
            
            labelCalories.topAnchor.constraint(equalTo: wrapperCellView.topAnchor, constant: 2),
            labelCalories.leadingAnchor.constraint(equalTo: wrapperCellView.leadingAnchor, constant: 8),
            labelCalories.heightAnchor.constraint(equalToConstant: 20),
            labelCalories.trailingAnchor.constraint(equalTo: wrapperCellView.trailingAnchor, constant: -8),
            
            labelProtein.topAnchor.constraint(equalTo: labelCalories.bottomAnchor, constant: 2),
            labelProtein.leadingAnchor.constraint(equalTo: wrapperCellView.leadingAnchor, constant: 8),
            labelProtein.heightAnchor.constraint(equalToConstant: 20),
            labelProtein.trailingAnchor.constraint(equalTo: wrapperCellView.trailingAnchor, constant: -8),
            
            labelCarbs.topAnchor.constraint(equalTo: labelProtein.bottomAnchor, constant: 2),
            labelCarbs.leadingAnchor.constraint(equalTo: wrapperCellView.leadingAnchor, constant: 8),
            labelCarbs.heightAnchor.constraint(equalToConstant: 20),
            labelCarbs.trailingAnchor.constraint(equalTo: wrapperCellView.trailingAnchor, constant: -8),
            
            labelFat.topAnchor.constraint(equalTo: labelCarbs.bottomAnchor, constant: 2),
            labelFat.leadingAnchor.constraint(equalTo: wrapperCellView.leadingAnchor, constant: 8),
            labelFat.heightAnchor.constraint(equalToConstant: 20),
            labelFat.trailingAnchor.constraint(equalTo: wrapperCellView.trailingAnchor, constant: -8),
            
            wrapperCellView.heightAnchor.constraint(equalToConstant: 110)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

