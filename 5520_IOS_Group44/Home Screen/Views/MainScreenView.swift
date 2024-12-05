//
//  MainScreenView.swift
//  5520_IOS_Group44
//
//  Created by Ninghui Cai on 11/21/24.
//

import UIKit

class MainScreenView: UIView {

    var profilePic: UIImageView!
    var labelText: UILabel!
    var addLogButton: UIButton!
    var addLogLabel: UILabel!
    var tableViewLogs: UITableView!
    
    override init(frame: CGRect){
        super.init(frame: frame)
        self.backgroundColor = .white
        
        setupProfilePic()
        setupLabelText()
        setupAddLogButtonAndLabel()
        setupTableViewLogs()
        
        initConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupProfilePic(){
        profilePic = UIImageView()
        profilePic.image = UIImage(systemName: "person.circle")?.withRenderingMode(.alwaysOriginal)
        profilePic.contentMode = .scaleToFill
        profilePic.clipsToBounds = true
        profilePic.layer.masksToBounds = true
        profilePic.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(profilePic)
    }
    
    func setupLabelText(){
        labelText = UILabel()
        labelText.font = .boldSystemFont(ofSize: 14)
        labelText.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(labelText)
    }
    
    func setupAddLogButtonAndLabel() {
        // Add Log Button
        addLogButton = UIButton(type: .system)
        addLogButton.setTitle("+", for: .normal)
        addLogButton.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        addLogButton.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(addLogButton)

        // Add Log Label
        addLogLabel = UILabel()
        addLogLabel.text = "Add New Log"
        addLogLabel.font = UIFont.systemFont(ofSize: 16)
        addLogLabel.textColor = .gray
        addLogLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(addLogLabel)
    }

    
    func setupTableViewLogs(){
        tableViewLogs = UITableView()
        tableViewLogs.register(LogsTableViewCell.self, forCellReuseIdentifier: Configs.tableViewLogsID)
        tableViewLogs.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(tableViewLogs)
    }
    
    func initConstraints(){
        NSLayoutConstraint.activate([
            profilePic.widthAnchor.constraint(equalToConstant: 32),
            profilePic.heightAnchor.constraint(equalToConstant: 32),
            profilePic.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 8),
            profilePic.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            
            labelText.topAnchor.constraint(equalTo: profilePic.topAnchor),
            labelText.bottomAnchor.constraint(equalTo: profilePic.bottomAnchor),
            labelText.leadingAnchor.constraint(equalTo: profilePic.trailingAnchor, constant: 8),
            
            // Add Log Button
            addLogButton.topAnchor.constraint(equalTo: profilePic.bottomAnchor, constant: 16),
            addLogButton.leadingAnchor.constraint(equalTo: profilePic.leadingAnchor),
            addLogButton.widthAnchor.constraint(equalToConstant: 40),
            addLogButton.heightAnchor.constraint(equalToConstant: 40),

            // Add Log Label
            addLogLabel.centerYAnchor.constraint(equalTo: addLogButton.centerYAnchor),
            addLogLabel.leadingAnchor.constraint(equalTo: addLogButton.trailingAnchor, constant: 8),
            
            tableViewLogs.topAnchor.constraint(equalTo: addLogButton.bottomAnchor, constant: 8),
            tableViewLogs.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            tableViewLogs.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableViewLogs.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -16),
        ])
    }

}

