//
//  PerformanceMonitor.swift
//  JLConsoleLog
//
//  Created by jack on 2020/5/6.
//  Copyright © 2020 jack. All rights reserved.
//

import Foundation

public let PerformanceMonitorNotification = NSNotification.Name(rawValue:"PerformanceMonitorNotification")

public class PerformanceMonitor {
   

    public enum monitorType {
        case cpu, memory
    }
    
    
    public static let shared = PerformanceMonitor()
    private var monitoringTimer: DispatchSourceTimer?
    public struct DisplayOptions: OptionSet {
        public let rawValue: Int
        public static let cpu = DisplayOptions(rawValue: 1 << 0)
        public static let memory = DisplayOptions(rawValue: 1 << 1)
        public static let all: DisplayOptions = [.cpu, .memory]
        public init(rawValue:Int) {
            self.rawValue = rawValue
        }
    }
    
    private var displayOptions: DisplayOptions = .all
    
    public init(displayOptions: DisplayOptions = .all){
        self.displayOptions = displayOptions
    }
    
    
    public func start() {
        monitoringTimer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.global())
        monitoringTimer?.schedule(deadline: .now(), repeating: 1)
        monitoringTimer?.setEventHandler(handler:{ [weak self] in
            DispatchQueue.main.async {
                guard let strongSelf = self else { return }
                var monitorReslut:[monitorType:String] = [monitorType:String]()
                if strongSelf.displayOptions.contains(.cpu) {
                    let cpuStr = String(format: "%.1f", CPUMonitor.usage())
                    monitorReslut[.cpu] = cpuStr
                }
                if strongSelf.displayOptions.contains(.memory) {
                    let memoryStr = String(format: "%.1f", MemoryMonitor.usage())
                    monitorReslut[.memory] = memoryStr
                }
                
                JLConsoleLogManager.consoleLogNotificationCenter.post(name: PerformanceMonitorNotification, object: monitorReslut)
            }
        })
        
        monitoringTimer?.resume()
    }
    
    public func stop() {
        monitoringTimer?.cancel()
    }
    
    public func pause() {
        monitoringTimer?.suspend()
    }
    
    public func resume() {
        monitoringTimer?.resume()
    }
    
    deinit {
        monitoringTimer?.cancel()
    }
}
