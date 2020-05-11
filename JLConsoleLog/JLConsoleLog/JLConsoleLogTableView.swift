//
//  JLConsoleLogTableView.swift
//  JLConsoleLog
//
//  Created by jack on 2020/4/26.
//  Copyright © 2020 jack. All rights reserved.
//

import UIKit

private let cellHeight:CGFloat = 22
private let cellIdentifier = "cellIdentifier"

class JLConsoleLogTableView: UITableView, UITableViewDelegate, UITableViewDataSource{
    
    // MARK: - property
    public var dataArray:[JLConsoleLogModel] = [JLConsoleLogModel]()
    
    // MARK: - functions
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style:style)
        self.dataArray = JLConsoleController.shared.logManager.filteredLogArray
        self.backgroundColor = UIColor.clear
        self.delegate = self
        self.dataSource = self
        JLConsoleLogManager.consoleLogNotificationCenter .addObserver(forName: AllLogsDidChangeNotification, object: nil, queue: .main, using: { [weak self] notification in
            guard let strongSelf = self else { return }
            strongSelf.dataArray = JLConsoleController.shared.logManager.filteredLogArray
            strongSelf.reloadData()
        })
        
        JLConsoleLogManager.consoleLogNotificationCenter.addObserver(forName: FilterSettingChangeNotification, object: nil, queue: .main, using: { [weak self] notification in
            guard let strongSelf = self else { return }
            strongSelf.dataArray = JLConsoleController.shared.logManager.filteredLogArray
            strongSelf.reloadData()
        })
        self.estimatedRowHeight = 0;
        self.estimatedSectionFooterHeight = 0;
        self.estimatedSectionHeaderHeight = 0;
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let sv = self.superview else {
            return
        }
        self.frame = sv.bounds
    }
    
    override func reloadData() {
        super.reloadData()
        if self.contentOffset.y == 0 && self.dataArray.count > 0 {
            guard self.contentSize.height > self.frame.size.height else{
                return
            }
            let offset = CGPoint(x: 0, y: self.contentSize.height - self.frame.size.height)
            self.setContentOffset(offset, animated: true)
            return
        }
        
        if self.contentSize.height > self.frame.size.height {
            let offset = CGPoint(x: 0, y: self.contentSize.height - self.frame.size.height)
            if offset.y - self.contentOffset.y > cellHeight * 5 {
                return
            }
            
            self.setContentOffset(offset, animated: true)
        }
    }
    
    // MARK: - UITableViewDelegate & UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
        }
        let log = self.dataArray[indexPath.row]
        cell?.textLabel?.text = "[\(log.level.rawValue)] \(log.info)"
        switch log.level {
        case .Error,.Critical:
            cell?.textLabel?.textColor = UIColor.red
        case .Warning, .Notice:
            cell?.textLabel?.textColor = UIColor.yellow
        default:
            cell?.textLabel?.textColor = UIColor.green
        }
        
        cell?.backgroundColor = UIColor.clear
        cell?.contentView.backgroundColor = UIColor.clear
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let log = self.dataArray[indexPath.row]
        let detailViewController = JLConsoleLogDetailViewController(style: .plain, log: log)
        let nvc = UINavigationController(rootViewController: detailViewController)
        if #available(iOS 13, *) {
            self.window?.rootViewController?.modalPresentationStyle = .currentContext
            self.window?.rootViewController?.present(nvc, animated: true, completion: nil)
        } else {
            self.parentViewController?.modalPresentationStyle = .currentContext
            self.parentViewController?.present(nvc, animated: true, completion: nil)
        }
        
    }
}

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder?.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
