//
//  MessageCell.swift
//  5520_IOS_Group44
//
//  Created by Bin Yang on 12/1/24.
//

import UIKit

class MessageCell: UITableViewCell {
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    private let bubbleBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        return view
    }()
    
    private var leadingConstraint: NSLayoutConstraint?
    private var trailingConstraint: NSLayoutConstraint?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        contentView.addSubview(bubbleBackgroundView)
        bubbleBackgroundView.addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            bubbleBackgroundView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            bubbleBackgroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            bubbleBackgroundView.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.75),
            
            messageLabel.topAnchor.constraint(equalTo: bubbleBackgroundView.topAnchor, constant: 12),
            messageLabel.bottomAnchor.constraint(equalTo: bubbleBackgroundView.bottomAnchor, constant: -12),
            messageLabel.leadingAnchor.constraint(equalTo: bubbleBackgroundView.leadingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleBackgroundView.trailingAnchor, constant: -12),
        ])
        
        leadingConstraint = bubbleBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12)
        trailingConstraint = bubbleBackgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12)
    }
    
    func configure(with message: Message) {
        messageLabel.text = message.content
        
        leadingConstraint?.isActive = false
        trailingConstraint?.isActive = false
        
        if message.isFromUser {
            bubbleBackgroundView.backgroundColor = .systemBlue
            messageLabel.textColor = .white
            trailingConstraint?.isActive = true
            
            bubbleBackgroundView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else {
            bubbleBackgroundView.backgroundColor = .systemGray6
            messageLabel.textColor = .label
            leadingConstraint?.isActive = true
            
            bubbleBackgroundView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        }
        
        layoutIfNeeded()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        leadingConstraint?.isActive = false
        trailingConstraint?.isActive = false
        messageLabel.text = nil
    }
}
