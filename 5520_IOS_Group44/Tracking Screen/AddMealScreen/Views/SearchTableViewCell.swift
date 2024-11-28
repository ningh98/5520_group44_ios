//
//  SearchTableViewCell.swift
//  5520_IOS_Group44
//
//  Created by Ninghui Cai on 11/23/24.
//

import UIKit

class SearchTableViewCell: UITableViewCell {
    
    var wrapperCellView: UIView!
    var labelTitle: UILabel!
    var labelDescription: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupWrapperCellVIew()
        setupLabelTitle()
        setupLabelDescription()
        initConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupWrapperCellVIew(){
        wrapperCellView = UITableViewCell()
        wrapperCellView.backgroundColor = .white
        wrapperCellView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(wrapperCellView)
    }
    func setupLabelTitle(){
        labelTitle = UILabel()
        labelTitle.font = UIFont.boldSystemFont(ofSize: 20)
        labelTitle.translatesAutoresizingMaskIntoConstraints = false
        wrapperCellView.addSubview(labelTitle)
    }
    func setupLabelDescription() {
        labelDescription = UILabel()
        labelDescription.font = UIFont.systemFont(ofSize: 14)
        labelDescription.textColor = .gray
        labelDescription.numberOfLines = 1 // Show only one line of text
        labelDescription.translatesAutoresizingMaskIntoConstraints = false
        wrapperCellView.addSubview(labelDescription)
    }

    func initConstraints(){
        NSLayoutConstraint.activate([
            wrapperCellView.topAnchor.constraint(equalTo: self.topAnchor,constant: 10),
            wrapperCellView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            wrapperCellView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10),
            wrapperCellView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            
            labelTitle.topAnchor.constraint(equalTo: wrapperCellView.topAnchor, constant: 8),
            labelTitle.leadingAnchor.constraint(equalTo: wrapperCellView.leadingAnchor, constant: 16),
            labelTitle.trailingAnchor.constraint(equalTo: wrapperCellView.trailingAnchor, constant:  -16),
            labelTitle.heightAnchor.constraint(equalToConstant: 20),
            
            labelDescription.topAnchor.constraint(equalTo: labelTitle.bottomAnchor, constant: 4),
            labelDescription.leadingAnchor.constraint(equalTo: wrapperCellView.leadingAnchor),
            labelDescription.trailingAnchor.constraint(equalTo: wrapperCellView.trailingAnchor),
            labelDescription.bottomAnchor.constraint(lessThanOrEqualTo: wrapperCellView.bottomAnchor),
            
            wrapperCellView.heightAnchor.constraint(equalToConstant: 50)
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
