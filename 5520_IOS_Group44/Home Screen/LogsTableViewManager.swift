//
//  LogsTableViewManager.swift
//  5520_IOS_Group44
//
//  Created by Ninghui Cai on 11/21/24.
//

import Foundation
import UIKit

extension MainScreenViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Configs.tableViewLogsID, for: indexPath) as! LogsTableViewCell
        
        // Create a DateFormatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        // Convert Date to String
        let formattedDate = dateFormatter.string(from: logsList[indexPath.row].date)
        
        cell.labelDate.text = formattedDate
        cell.labelComment.text = logsList[indexPath.row].comment
        return cell
    }
}
