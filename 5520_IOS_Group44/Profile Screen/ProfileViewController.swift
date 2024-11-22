//
//  ProfileViewController.swift
//  5520_IOS_Group44
//
//  Created by Ninghui Cai on 11/21/24.
//

import UIKit

class ProfileViewController: UIViewController {

    let profileView = ProfileView()
    
    override func loadView(){
        view = profileView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Profile"
        
    }

}
