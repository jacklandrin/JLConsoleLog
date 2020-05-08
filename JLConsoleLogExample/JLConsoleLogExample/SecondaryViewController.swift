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

    var highCPUSwitch:Bool = false
    var highMemorySwitch:Bool = false
    var cpuThread:Thread?
    var memoryThread:Thread?
    
    var addMemory:UnsafeMutableRawPointer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        
        let infoButton = UIButton(frame: CGRect(x: 100, y: 300, width: 200, height: 40))
        infoButton.setTitle("add an info log", for: .normal)
        infoButton.setTitleColor(.green, for: .normal)
        infoButton.backgroundColor = .purple
        infoButton.addTarget(self, action: #selector(addInfoLog(button:)), for: .touchUpInside)
        self.view.addSubview(infoButton)
        
        let warningButton = UIButton(frame: CGRect(x: 100, y: 350, width: 200, height: 40))
        warningButton.setTitle("add a warning log", for: .normal)
        warningButton.setTitleColor(.green, for: .normal)
        warningButton.backgroundColor = .gray
        warningButton.addTarget(self, action: #selector(addWarningLog(button:)), for: .touchUpInside)
        self.view.addSubview(warningButton)
        
        let errorButton = UIButton(frame: CGRect(x: 100, y: 400, width: 200, height: 40))
        errorButton.setTitle("add an error log", for: .normal)
        errorButton.setTitleColor(.systemPink, for: .normal)
        errorButton.backgroundColor = .blue
        errorButton.addTarget(self, action: #selector(addErrorLog(button:)), for: .touchUpInside)
        self.view.addSubview(errorButton)
    
        let highCPUButton = UIButton(frame: CGRect(x: 100, y: 450, width: 200, height: 40))
        highCPUButton.setTitle("high cpu", for: .normal)
        highCPUButton.setTitleColor(.purple, for: .normal)
        highCPUButton.backgroundColor = .green
        highCPUButton.addTarget(self, action: #selector(highCPU(button:)), for: .touchUpInside)
        self.view.addSubview(highCPUButton)
        
        let highMemoryButton = UIButton(frame: CGRect(x: 100, y: 500, width: 200, height: 40))
        highMemoryButton.setTitle("high memory", for: .normal)
        highMemoryButton.setTitleColor(.yellow, for: .normal)
        highMemoryButton.backgroundColor = .gray
        highMemoryButton.addTarget(self, action: #selector(highMemory(button:)), for: .touchUpInside)
        self.view.addSubview(highMemoryButton)
        
        
        JLConsoleController.shared.register(newCategory: SubPageTestLog)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        highCPUSwitch = false
        cpuThread?.cancel()
        cpuThread = nil
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
    
    @objc func highCPU(button:UIButton) {
        if highCPUSwitch {
            highCPUSwitch = false
            cpuThread?.cancel()
            cpuThread = nil
            
            button.setTitle("high cpu", for: .normal)
        } else {
            highCPUSwitch = true
            cpuThread = Thread(target: self, selector: #selector(highCPUOperation), object: nil)
            cpuThread?.name = "HighCPUThread"
            cpuThread?.start()
            button.setTitle("low cpu", for: .normal)
        }
    }
    
    @objc func highCPUOperation() {
        while true {
            if Thread.current.isCancelled {
                Thread.exit()
            }
        }
    }
    
    @objc func highMemory(button:UIButton) {
        if highMemorySwitch {
            highMemorySwitch = false
            memoryThread?.cancel()
            memoryThread = nil
            button.setTitle("high memory", for: .normal)
        } else {
            highMemorySwitch = true
            memoryThread = Thread(target: self, selector: #selector(highMemoryOperation), object: nil)
            memoryThread?.name = "HighMemoryThread"
            memoryThread?.start()
            button.setTitle("low memory", for: .normal)
        }
    }
    
    
    @objc func highMemoryOperation() {
        let addedMemSize:Int = 400
        let interval:Int = 2
        while true {
            if Thread.current.isCancelled {
                Thread.exit()
            }
            
            if addMemory == nil {
                addMemory = UnsafeMutableRawPointer.allocate(byteCount: 1024*1024*addedMemSize, alignment: 0)
                if addMemory != nil {
                    memset(addMemory, 0, 1024*1024*addedMemSize)
                } else {
                    print("add mem failed")
                }
            }
            
            Thread.sleep(forTimeInterval: TimeInterval(interval))
            if Thread.current.isCancelled {
                Thread.exit()
            }
            
            if addMemory != nil {
                addMemory?.deallocate()
                addMemory = nil
            }
            
            Thread.sleep(forTimeInterval: TimeInterval(interval))
            
        }
    }
}
