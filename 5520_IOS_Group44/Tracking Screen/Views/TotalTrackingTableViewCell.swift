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
        labelCalories.font = UIFont.boldSystemFont(ofSize: 14)
        labelCalories.translatesAutoresizingMaskIntoConstraints = false
        wrapperCellView.addSubview(labelCalories)
    }
    
    func setupLabelProtein(){
        labelProtein = UILabel()
        labelProtein.font = UIFont.boldSystemFont(ofSize: 14)
        labelProtein.translatesAutoresizingMaskIntoConstraints = false
        wrapperCellView.addSubview(labelProtein)
    }
    
    func setupLabelCarbs(){
        labelCarbs = UILabel()
        labelCarbs.font = UIFont.boldSystemFont(ofSize: 14)
        labelCarbs.translatesAutoresizingMaskIntoConstraints = false
        wrapperCellView.addSubview(labelCarbs)
    }
    
    func setupLabelFat(){
        labelFat = UILabel()
        labelFat.font = UIFont.boldSystemFont(ofSize: 14)
        labelFat.translatesAutoresizingMaskIntoConstraints = false
        wrapperCellView.addSubview(labelFat)
    }
    
    
    func initConstraints(){
        NSLayoutConstraint.activate([
            wrapperCellView.topAnchor.constraint(equalTo: self.topAnchor,constant: 10),
            wrapperCellView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            wrapperCellView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10),
            wrapperCellView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            
            labelCalories.topAnchor.constraint(equalTo: wrapperCellView.topAnchor, constant: 2),
            labelCalories.leadingAnchor.constraint(equalTo: wrapperCellView.leadingAnchor, constant: 16),
            labelCalories.heightAnchor.constraint(equalToConstant: 20),
            labelCalories.widthAnchor.constraint(lessThanOrEqualTo: wrapperCellView.widthAnchor),
            
            labelProtein.topAnchor.constraint(equalTo: labelCalories.bottomAnchor, constant: 2),
            labelProtein.leadingAnchor.constraint(equalTo: labelCalories.leadingAnchor),
            labelProtein.heightAnchor.constraint(equalToConstant: 16),
            labelProtein.widthAnchor.constraint(lessThanOrEqualTo: labelCalories.widthAnchor),
            
            labelCarbs.topAnchor.constraint(equalTo: labelProtein.bottomAnchor, constant: 2),
            labelCarbs.leadingAnchor.constraint(equalTo: labelProtein.leadingAnchor),
            labelCarbs.heightAnchor.constraint(equalToConstant: 16),
            labelCarbs.widthAnchor.constraint(lessThanOrEqualTo: labelProtein.widthAnchor),
            
            labelFat.topAnchor.constraint(equalTo: labelCarbs.bottomAnchor, constant: 2),
            labelFat.leadingAnchor.constraint(equalTo: labelCarbs.leadingAnchor),
            labelFat.heightAnchor.constraint(equalToConstant: 16),
            labelFat.widthAnchor.constraint(lessThanOrEqualTo: labelCarbs.widthAnchor),
            
            wrapperCellView.heightAnchor.constraint(equalToConstant: 80)
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

