//
//  JLConsoleCanvasView.swift
//  JLConsoleLog
//
//  Created by jack on 2020/4/26.
//  Copyright © 2020 jack. All rights reserved.
//

import UIKit

private let searchBarHeight:CGFloat = 40.0

class JLConsoleCanvasView: UIView {

    // MARK: - property
    lazy private var canvasScrollView: UIScrollView = {
        let canvasScrollView = UIScrollView(frame: self.bounds)
        
        if #available(iOS 11.0, *) {
            canvasScrollView.contentInsetAdjustmentBehavior = .always
        }
        return canvasScrollView
    }()
    
    lazy private var searchBar: UISearchBar = {
        let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: searchBarHeight))
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        searchBar.isHidden = true
        
        return searchBar
    }()
    
    lazy private var consoleLogTableView: JLConsoleLogTableView = {
        let consoleLogTableView = JLConsoleLogTableView(frame: self.bounds, style: .plain)
        
        return consoleLogTableView
    }()
    
    public var isShowSearchBar:Bool = false
    {
        didSet {
            if isShowSearchBar {
                searchBar.isHidden = false
                canvasScrollView.frame = CGRect(x: canvasScrollView.frame.origin.x, y:searchBarHeight, width: self.frame.height - searchBarHeight, height: canvasScrollView.frame.height)
            } else {
                searchBar.isHidden = true
                canvasScrollView.frame = self.bounds
            }
        }
    }
    
    // MARK: - function
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(canvasScrollView)
        self.addSubview(searchBar)
        self.canvasScrollView.addSubview(consoleLogTableView)
        self.consoleLogTableView.reloadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        canvasScrollView.frame = self.bounds
        consoleLogTableView.frame = self.bounds
        searchBar.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: searchBarHeight)
        if isShowSearchBar {
            searchBar.isHidden = false
            canvasScrollView.frame = CGRect(x: canvasScrollView.frame.origin.x, y:searchBarHeight, width: self.frame.height - searchBarHeight, height: canvasScrollView.frame.height)
        } else {
            searchBar.isHidden = true
            canvasScrollView.frame = self.bounds
        }
    }
    
    
    
}

//UISearchBarDelegate
extension JLConsoleCanvasView: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let charSet = CharacterSet.whitespacesAndNewlines
        var keywords:Set<String> = Set<String>()
        for string in searchText.components(separatedBy: " ") {
            let trimmedString = string.trimmingCharacters(in: charSet)
            if trimmedString.count > 0 {
                keywords.insert(trimmedString)
            }
        }
        
        JLConsoleController.shared.logManager.filterKeywords = keywords
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
