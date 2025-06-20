//
//  LogsTableViewCell.swift
//  5520_IOS_Group44
//
//  Created by Ninghui Cai on 11/21/24.
//

import UIKit

class LogsTableViewCell: UITableViewCell {
    
    var wrapperCellView: UIView!
    var labelDate: UILabel!
    var labelComment: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupWrapperCellView()
        setupLabelDate()
        setupLabelComment()
        
        initConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    
    func setupLabelDate(){
        labelDate = UILabel()
        labelDate.font = UIFont.boldSystemFont(ofSize: 20)
        labelDate.translatesAutoresizingMaskIntoConstraints = false
        wrapperCellView.addSubview(labelDate)
    }
    
    func setupLabelComment(){
        labelComment = UILabel()
        labelComment.font = UIFont.boldSystemFont(ofSize: 14)
        labelComment.translatesAutoresizingMaskIntoConstraints = false
        wrapperCellView.addSubview(labelComment)
    }
    
    func initConstraints(){
        NSLayoutConstraint.activate([
            wrapperCellView.topAnchor.constraint(equalTo: self.topAnchor,constant: 10),
            wrapperCellView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            wrapperCellView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10),
            wrapperCellView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            
            labelDate.topAnchor.constraint(equalTo: wrapperCellView.topAnchor, constant: 8),
            labelDate.leadingAnchor.constraint(equalTo: wrapperCellView.leadingAnchor, constant: 16),
            labelDate.heightAnchor.constraint(equalToConstant: 20),
            labelDate.widthAnchor.constraint(lessThanOrEqualTo: wrapperCellView.widthAnchor),
            
            labelComment.topAnchor.constraint(equalTo: labelDate.bottomAnchor, constant: 2),
            labelComment.leadingAnchor.constraint(equalTo: labelDate.leadingAnchor),
            labelComment.heightAnchor.constraint(equalToConstant: 16),
            labelComment.widthAnchor.constraint(lessThanOrEqualTo: labelDate.widthAnchor),
            
            wrapperCellView.heightAnchor.constraint(equalToConstant: 72)
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

