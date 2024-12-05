//
//  AddedFoodTableViewCell.swift
//  5520_IOS_Group44
//
//  Created by Ninghui Cai on 12/4/24.
//

import UIKit

class AddedFoodTableViewCell: UITableViewCell {
    
    var wrapperCellView: UIView!
    var labelFoodName: UILabel!
    var labelNutrients: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupWrapperCellView()
        setupLabelFoodName()
        setupLabelNutrients()
        initConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupWrapperCellView() {
        wrapperCellView = UIView()
        wrapperCellView.backgroundColor = .white
        wrapperCellView.layer.cornerRadius = 10
        wrapperCellView.layer.shadowColor = UIColor.black.cgColor
        wrapperCellView.layer.shadowOpacity = 0.1
        wrapperCellView.layer.shadowOffset = CGSize(width: 0, height: 2)
        wrapperCellView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(wrapperCellView)
    }
    
    private func setupLabelFoodName() {
        labelFoodName = UILabel()
        labelFoodName.font = UIFont.boldSystemFont(ofSize: 18)
        labelFoodName.translatesAutoresizingMaskIntoConstraints = false
        wrapperCellView.addSubview(labelFoodName)
    }
    
    private func setupLabelNutrients() {
        labelNutrients = UILabel()
        labelNutrients.font = UIFont.systemFont(ofSize: 14)
        labelNutrients.textColor = .gray
        labelNutrients.numberOfLines = 1
        labelNutrients.translatesAutoresizingMaskIntoConstraints = false
        wrapperCellView.addSubview(labelNutrients)
    }
    
    private func initConstraints() {
        NSLayoutConstraint.activate([
            wrapperCellView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            wrapperCellView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            wrapperCellView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10),
            wrapperCellView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            
            labelFoodName.topAnchor.constraint(equalTo: wrapperCellView.topAnchor, constant: 10),
            labelFoodName.leadingAnchor.constraint(equalTo: wrapperCellView.leadingAnchor, constant: 16),
            labelFoodName.trailingAnchor.constraint(equalTo: wrapperCellView.trailingAnchor, constant: -16),
            
            labelNutrients.topAnchor.constraint(equalTo: labelFoodName.bottomAnchor, constant: 5),
            labelNutrients.leadingAnchor.constraint(equalTo: wrapperCellView.leadingAnchor, constant: 16),
            labelNutrients.trailingAnchor.constraint(equalTo: wrapperCellView.trailingAnchor, constant: -16),
            labelNutrients.bottomAnchor.constraint(lessThanOrEqualTo: wrapperCellView.bottomAnchor, constant: -10)
        ])
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
