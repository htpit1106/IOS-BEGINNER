//
//  ReminderListViewController+DataSource.swift
//  Today
//
//  Created by Admin on 10/3/25.
//

import UIKit


extension ReminderListViewController {
    typealias DataSource = UICollectionViewDiffableDataSource<Int, String>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, String>
    
    func cellRegistrationHandler(cell: UICollectionViewListCell, indexPath: IndexPath, id: String) {
        let reminder = Reminder.sampleData[indexPath.item]
        var contentConfiguration = cell.defaultContentConfiguration()
        contentConfiguration.secondaryText = reminder.dueDate.dayAndTimeText
        
        let status = reminder.status
        let dotLabel = UILabel()
        dotLabel.text = "●"
        dotLabel.font = UIFont.systemFont(ofSize: 12)
        dotLabel.textColor = {
            switch status {
            case "warnning":
                return UIColor.yellow
            case "error":
                return UIColor.red
            case "success":
                return UIColor.green
            default: return UIColor.darkGray
            }
        }()
        contentConfiguration.text = reminder.title + dotLabel.text!
        contentConfiguration.attributedText = NSAttributedString(string: reminder.title)
        cell.contentConfiguration = contentConfiguration

//        cell.accessories = [.customView(configuration: .init(customView: dotLabel, placement: .trailing()))];
        var backgroundConfiguration = UIBackgroundConfiguration.listCell()
                backgroundConfiguration.backgroundColor = UIColor.systemGray6
                cell.backgroundConfiguration = backgroundConfiguration
    }
    
   
}

