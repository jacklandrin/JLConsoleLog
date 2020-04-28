//
//  SecondaryViewController.swift
//  JLConsoleLog
//
//  Created by jack on 2020/4/28.
//  Copyright © 2020 jack. All rights reserved.
//

import UIKit
import JLConsoleLog

let SubPageTestLog:JLConsoleLogCategory = "com.consolelog.mybusiness"

class SecondaryViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        
        let infoButton = UIButton(frame: CGRect(x: 100, y: 350, width: 200, height: 40))
        infoButton.setTitle("add an info log", for: .normal)
        infoButton.setTitleColor(.green, for: .normal)
        infoButton.backgroundColor = .purple
        infoButton.addTarget(self, action: #selector(addInfoLog(button:)), for: .touchUpInside)
        self.view.addSubview(infoButton)
        
        let warningButton = UIButton(frame: CGRect(x: 100, y: 400, width: 200, height: 40))
        warningButton.setTitle("add a warning log", for: .normal)
        warningButton.setTitleColor(.green, for: .normal)
        warningButton.backgroundColor = .gray
        warningButton.addTarget(self, action: #selector(addWarningLog(button:)), for: .touchUpInside)
        self.view.addSubview(warningButton)
        
        let errorButton = UIButton(frame: CGRect(x: 100, y: 450, width: 200, height: 40))
        errorButton.setTitle("add an error log", for: .normal)
        errorButton.setTitleColor(.systemPink, for: .normal)
        errorButton.backgroundColor = .blue
        errorButton.addTarget(self, action: #selector(addErrorLog(button:)), for: .touchUpInside)
        self.view.addSubview(errorButton)
        
        JLConsoleController.shared.register(newCategory: SubPageTestLog)
    }
    

    @objc func addInfoLog(button:UIButton) {
        JLInfoLog(category: SubPageTestLog, contextData: ["test":3], formats: "some info...",#function,String(#line))
    }

    
    @objc func addWarningLog(button:UIButton) {
        JLWarningLog(category: SubPageTestLog, needPrint: true, contextData: ["test":4], formats: "Warning!",#function,String(#line))
    }
    
    @objc func addErrorLog(button:UIButton) {
        JLErrorLog(category: SubPageTestLog, hasFollowingAction: true ,needPrint: true, contextData: ["test":5], formats: "Error!",#function,String(#line))
    }
}
