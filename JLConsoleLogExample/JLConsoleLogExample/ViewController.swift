//
//  ViewController.swift
//  JLConsoleLog
//
//  Created by jack on 2020/4/25.
//  Copyright © 2020 jack. All rights reserved.
//

import UIKit
import JLConsoleLog

let TestLog:JLConsoleLogCategory = "com.consolelog.test"

class ViewController: UIViewController {

    var count:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let showConsoleButton = UIButton(frame: CGRect(x: 100, y: 300, width: 200, height: 40))
        showConsoleButton.setTitle("show console", for: .normal)
        showConsoleButton.setTitleColor(.cyan, for: .normal)
        showConsoleButton.backgroundColor = .black
        showConsoleButton.addTarget(self, action: #selector(pressShowButton(button:)), for: .touchUpInside)
        self.view.addSubview(showConsoleButton)
        
        let startLogButton = UIButton(frame: CGRect(x: 100, y: 350, width: 200, height: 40))
        startLogButton.setTitle("start to log", for: .normal)
        startLogButton.setTitleColor(.green, for: .normal)
        startLogButton.backgroundColor = .purple
        startLogButton.addTarget(self, action: #selector(startLog(button:)), for: .touchUpInside)
        self.view.addSubview(startLogButton)
        
        let addDebugLogButton = UIButton(frame: CGRect(x: 100, y: 400, width: 200, height: 40))
        addDebugLogButton.setTitle("add a debug log", for: .normal)
        addDebugLogButton.setTitleColor(.green, for: .normal)
        addDebugLogButton.backgroundColor = .gray
        addDebugLogButton.addTarget(self, action: #selector(addDebugLog(button:)), for: .touchUpInside)
        self.view.addSubview(addDebugLogButton)
        
        let nextPageButton = UIButton(frame: CGRect(x: 100, y: 450, width: 200, height: 40))
        nextPageButton.setTitle("next page", for: .normal)
        nextPageButton.setTitleColor(.systemPink, for: .normal)
        nextPageButton.backgroundColor = .blue
        nextPageButton.addTarget(self, action: #selector(gotoNextPage(button:)), for: .touchUpInside)
        self.view.addSubview(nextPageButton)
        
        
        if #available(iOS 10.0, *) {
            let _ = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: { _ in
                JLVerboseLog(category: TestLog, needPrint: true , contextData: ["test":1], formats: String(self.count), #function,String(#line))
                self.count += 1
            })
        }
        
        JLConsoleLogManager.consoleLogNotificationCenter.addObserver(forName: ConsoleHasDismissedNotification, object: nil, queue: .main, using: { _ in
            showConsoleButton.setTitle("show console", for: .normal)
        })
        
        JLConsoleController.shared.followingAction = { options in
            print("add a log \(options.level.rawValue)  \(options.category)")
            //send a track log to server or other actions
        }
        
        JLConsoleController.shared.register(newCategory: TestLog) //registered category could be filtered
    }

    @objc func pressShowButton(button:UIButton) {
        if JLConsoleController.shared.style == .Hidden {
            button.setTitle("hide console", for: .normal)
            JLConsoleController.shared.style = .Floating //show console in floating fashion
        } else {
            button.setTitle("show console", for: .normal)
            JLConsoleController.shared.style = .Hidden //hide console
        }
        
    }
    
    @objc func startLog(button:UIButton) {
        if JLConsoleController.shared.logEnabled {
            JLConsoleController.shared.logEnabled = false
            button.setTitle("start to log", for: .normal)
        } else {
            JLConsoleController.shared.logEnabled = true
             button.setTitle("end to log", for: .normal)
        }
    }
    
    @objc func addDebugLog(button:UIButton) {
        JLDebugLog(category: TestLog,hasFollowingAction: true, contextData: ["test":2], formats: "debug info", #function,String(#line))
    }
    
    @objc func gotoNextPage(button:UIButton) {
        let vc = SecondaryViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

