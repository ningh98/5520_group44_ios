//
//  FastingViewController.swift
//  5520_IOS_Group44
//
//  Created by Ninghui Cai on 11/21/24.
//

import UIKit

class FastingViewController: UIViewController {

    let fastingView = FastingView()
    
    override func loadView(){
        view = fastingView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Fasting"
        
    }

}
