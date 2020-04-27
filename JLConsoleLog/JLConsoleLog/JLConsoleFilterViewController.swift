//
//  JLConsoleFilterViewController.swift
//  JLConsoleLog
//
//  Created by jack on 2020/4/27.
//  Copyright © 2020 jack. All rights reserved.
//

import UIKit

fileprivate let cellIdentifier = "cellIdentifier"

struct FilterModel {
    var title: String
    var isSelectd: Bool
}

enum FilterType {
    case Category
    case Level
}

class JLConsoleFilterViewController: UITableViewController {
    // MARK: - property
    public var dataArray:[FilterModel] = [FilterModel]()
    public var filterType:FilterType = .Category
    
    // MARK: - function
    init(style: UITableView.Style, filterType:FilterType) {
        super.init(style: style)
        self.filterType = filterType
        switch self.filterType {
        case .Category:
            self.title = "category"
        case .Level:
            self.title = "level"
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let closeButton = UIBarButtonItem(title: "close", style: .plain, target: self, action: #selector(closeAction))
        self.navigationItem.rightBarButtonItem = closeButton
        self.tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
        
        var tempArray:[String]
        switch self.filterType {
        case .Category:
            tempArray = JLConsoleController.shared.allCategories
        case .Level:
            tempArray = [JLConsoleLogLevel.Verbose.rawValue, JLConsoleLogLevel.Debug.rawValue, JLConsoleLogLevel.Info.rawValue, JLConsoleLogLevel.Warning.rawValue, JLConsoleLogLevel.Error.rawValue]
        }
        
        var tempDataArray:[FilterModel] = [FilterModel]()
        for title in tempArray {
            var filter = FilterModel(title: title, isSelectd: false)
            switch self.filterType {
            case .Category:
                if JLConsoleController.shared.logManager.filterCategories.count == 0 {
                    filter.isSelectd = true
                } else {
                    filter.isSelectd = JLConsoleController.shared.logManager.filterCategories .contains(title)
                }
            case .Level:
                if JLConsoleController.shared.logManager.filterLevels.count == 0 {
                    filter.isSelectd = true
                } else {
                    filter.isSelectd = JLConsoleController.shared.logManager.filterLevels.contains(JLConsoleLogLevel(rawValue: title)!)
                }
            }
            tempDataArray.append(filter)
        }
        
        self.dataArray = tempDataArray
    }

    @objc func closeAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.dataArray.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
        }
        let filter = self.dataArray[indexPath.row]
        cell?.textLabel?.text = filter.title
        if filter.isSelectd {
            cell?.accessoryType = .checkmark
        } else {
            cell?.accessoryType = .none
        }
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var filter = self.dataArray[indexPath.row]
        filter.isSelectd.toggle()
        tableView.reloadData()
        let resultIndices = self.dataArray.indices.filter{self.dataArray[$0].isSelectd}
        switch self.filterType {
        case .Category:
            let result = Set(resultIndices.map{JLConsoleLogCategory(self.dataArray[$0].title)})
            JLConsoleController.shared.logManager.filterCategories = result
        case .Level:
            let result = Set(resultIndices.map{JLConsoleLogLevel(rawValue: self.dataArray[$0].title)!})
            JLConsoleController.shared.logManager.filterLevels = result
        }
    }
    

}
