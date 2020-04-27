//
//  JLConsoleLogDetailViewController.swift
//  JLConsoleLog
//
//  Created by jack on 2020/4/26.
//  Copyright © 2020 jack. All rights reserved.
//

import UIKit

private let cellIdentifier = "cellIdentifier"

class JLConsoleLogDetailViewController: UITableViewController {

    public var log: JLConsoleLogModel = JLConsoleLogModel()
    
    init(style: UITableView.Style, log:JLConsoleLogModel) {
        super.init(style: style)
        self.log = log
        let closeButton = UIBarButtonItem(title: "close", style: .plain, target: self, action: #selector(closeAction))
        self.navigationItem.rightBarButtonItem = closeButton
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func closeAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:JLConsoleLogDetailCell? = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? JLConsoleLogDetailCell
        if cell == nil {
            cell = JLConsoleLogDetailCell(style: .default, reuseIdentifier: cellIdentifier)
        }
        
        switch indexPath.row {
        case 0:
            cell?.titleLabel!.text = "info"
            cell?.detailStr = self.log.info
        case 1:
            cell?.titleLabel!.text = "level"
            cell?.detailStr = self.log.level.rawValue
        case 2:
            cell?.titleLabel!.text = "category"
            cell?.detailStr = self.log.category
        case 3:
            cell?.titleLabel!.text = "contextData"
            cell?.detailStr = self.log.invokingInfo
        case 4:
            cell?.titleLabel!.text = "time"
            let date = Date(timeIntervalSince1970: self.log.time)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY/MM/dd HH:mm:ss"
            let formattedDateStr = dateFormatter.string(from: date)
            cell?.detailStr = formattedDateStr
        default:
            break
        }

        return cell!
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell = self.tableView(tableView, cellForRowAt: indexPath) as! JLConsoleLogDetailCell
        return cell.cellHeight
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 3 {
            let pasteboard = UIPasteboard.general
            pasteboard.string = self.log.invokingInfo
        }
    }
    
}

class JLConsoleLogDetailCell: UITableViewCell {
    
    var titleLabel: UILabel?
    var detailStr: String = ""
    {
        didSet {
            detailLabel.text = detailStr
            let labelHeight = detailLabel.sizeThatFits(CGSize(width: self.frame.width - 20, height: CGFloat.greatestFiniteMagnitude)).height
            detailLabel.frame = CGRect(x: detailLabel.frame.origin.x, y:detailLabel.frame.origin.y , width: detailLabel.frame.width, height: labelHeight)
            self.cellHeight = labelHeight + 35
        }
    }
    var cellHeight: CGFloat = 0.0
    private var detailLabel:UILabel = UILabel()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.titleLabel = UILabel(frame: CGRect(x: 10, y: 5, width: self.frame.width - 20, height: 20))
        self.titleLabel!.textColor = UIColor.black
        self.titleLabel!.font = UIFont.boldSystemFont(ofSize: 18)
        self.addSubview(self.titleLabel!)
        
        self.detailLabel = UILabel(frame: CGRect(x: 10, y: 30, width: self.frame.width - 20, height: 20))
        self.detailLabel.textColor = UIColor.gray
        self.detailLabel.font = UIFont.systemFont(ofSize: 18)
        self.detailLabel.numberOfLines = 0
        self.detailLabel.lineBreakMode = .byWordWrapping
        self.addSubview(self.detailLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
