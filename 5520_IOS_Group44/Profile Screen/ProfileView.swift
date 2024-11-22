//
//  ProfileView.swift
//  5520_IOS_Group44
//
//  Created by Ninghui Cai on 11/21/24.
//

import UIKit

class ProfileView: UIView {

    var boxView: UIView!
    var textLabel: UILabel!
    
    override init(frame: CGRect){
        super.init(frame: frame)
        self.backgroundColor = .white
        
        setupBoxView()
        setupTextLabel()
        
        initConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupBoxView(){
        boxView = UIView()
        boxView.backgroundColor = .green
        boxView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(boxView)
    }
    
    func setupTextLabel(){
        textLabel = UILabel()
        textLabel.text = "Test Text for profile screen"
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(textLabel)
    }
    
    func initConstraints(){
        NSLayoutConstraint.activate([
            boxView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 32),
            boxView.widthAnchor.constraint(equalToConstant: 200),
            boxView.heightAnchor.constraint(equalToConstant: 200),
            boxView.centerXAnchor.constraint(equalTo: self.safeAreaLayoutGuide.centerXAnchor),
            
            
            
            textLabel.topAnchor.constraint(equalTo: self.boxView.bottomAnchor, constant: 8),
            textLabel.centerXAnchor.constraint(equalTo: self.safeAreaLayoutGuide.centerXAnchor),
        ])
    }

}
