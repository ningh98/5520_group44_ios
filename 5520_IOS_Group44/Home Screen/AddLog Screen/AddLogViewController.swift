//
//  AddLogViewController.swift
//  5520_IOS_Group44
//
//  Created by Ninghui Cai on 12/2/24.
//

import UIKit

class AddLogViewController: UIViewController {
    
    let addLogView = AddLogView() // Use the custom view
    var saveAction: ((Date, String) -> Void)? // Callback to pass data back to MainScreenViewController

    override func loadView() {
        view = addLogView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupActions()
        
    }
    

    private func setupActions() {
        // Assign button actions
        addLogView.saveButton.addTarget(self, action: #selector(saveLog), for: .touchUpInside)
        addLogView.cancelButton.addTarget(self, action: #selector(cancelLog), for: .touchUpInside)
    }
    
    @objc private func saveLog() {
        let selectedDate = addLogView.datePicker.date
        let comment = addLogView.commentTextField.text ?? ""
        saveAction?(selectedDate, comment) // Pass the data to the callback
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func cancelLog() {
        dismiss(animated: true, completion: nil)
    }

}
