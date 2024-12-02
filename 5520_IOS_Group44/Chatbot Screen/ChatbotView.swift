//
//  ChatbotView.swift
//  5520_IOS_Group44
//
//  Created by Bin Yang on 12/1/24.
//

import UIKit

class ChatbotView: UIView {
    // Chat messages table view
    let chatTableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    // Message input field
    let messageTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Type your message..."
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    // Send button
    let sendButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Send", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(chatTableView)
        addSubview(messageTextField)
        addSubview(sendButton)
        
        NSLayoutConstraint.activate([
            // Table view constraints
            chatTableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            chatTableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            chatTableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            chatTableView.bottomAnchor.constraint(equalTo: messageTextField.topAnchor, constant: -8),
            
            // Message text field constraints
            messageTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            messageTextField.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -8),
            messageTextField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),
            
            // Send button constraints
            sendButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            sendButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -8),
            sendButton.widthAnchor.constraint(equalToConstant: 60)
        ])
    }
}
