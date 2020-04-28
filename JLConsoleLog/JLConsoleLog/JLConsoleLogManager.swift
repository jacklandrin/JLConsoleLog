//
//  JLConsoleLogManager.swift
//  JLConsoleLog
//
//  Created by jack on 2020/4/26.
//  Copyright © 2020 jack. All rights reserved.
//

import Foundation

let AllLogCountLimit = 1000
let AllLogsDidChangeNotification = NSNotification.Name(rawValue:"AllLogsDidChangeNotification")
let FilterSettingChangeNotification = NSNotification.Name(rawValue:"FilterSettingChangeNotification")
let WarningCountChangeNotification = NSNotification.Name(rawValue: "WarningCountChangeNotification")
let ErrorCountChangeNotification = NSNotification.Name(rawValue: "ErrorCountChangeNotification")

class JLConsoleLogManager: NSObject {
    // MARK: - static property
    static let consoleLogNotificationCenter = NotificationCenter()
    
    // MARK: - public property
    public var filterLevels: Set<JLConsoleLogLevel> = []
    {
        didSet {
            dispatch_main_async_safe {[weak self] in
                guard let strongSelf = self else { return }
                strongSelf.reloadFilteredLogArray()
                strongSelf.notifyFilterSettingChange()
            }
            
        }
    }
    
    public var filterCategories: Set<JLConsoleLogCategory> = []
    {
        didSet {
            dispatch_main_async_safe {[weak self] in
                guard let strongSelf = self else { return }
                strongSelf.reloadFilteredLogArray()
                strongSelf.notifyFilterSettingChange()
            }
        }
    }
    
    public var filterKeywords: Set<String> = []
    {
        didSet {
            dispatch_main_async_safe {[weak self] in
                guard let strongSelf = self else { return }
                strongSelf.reloadFilteredLogArray()
                strongSelf.notifyFilterSettingChange()
            }
        }
    }
    
    public internal(set) var allLogArray:[JLConsoleLogModel] = [JLConsoleLogModel]()
    public internal(set) var filteredLogArray:[JLConsoleLogModel] = [JLConsoleLogModel]()
    public internal(set) var warningCount: UInt = 0
    {
        didSet{
            self.notifyWarningChange()
        }
    }
    public internal(set) var errorCount: UInt = 0
    {
        didSet{
            self.notifyErrorChange()
        }
    }
    public var logEnable: Bool = true
    // MARK: - private property
    private var pendingFilteredLogArray:[JLConsoleLogModel] = [JLConsoleLogModel]()
    // MARK: - public functions
    public func append(log:JLConsoleLogModel) {
        guard self.logEnable && log.info.count > 0 else {
            return
        }
        
        dispatch_main_async_safe { [weak self] in
            guard let strongSelf = self else { return }
            if strongSelf.allLogArray.count >= AllLogCountLimit {
                let warningArray = strongSelf.allLogArray[0...AllLogCountLimit / 2].filter{$0.level == .Warning}
                strongSelf.warningCount -= UInt(warningArray.count)
                
                let errorArray = strongSelf.allLogArray[0...AllLogCountLimit / 2].filter{$0.level == .Error}
                strongSelf.errorCount -= UInt(errorArray.count)
                
                strongSelf.allLogArray.removeSubrange(0...AllLogCountLimit / 2)
                strongSelf.reloadFilteredLogArray()
            }
            
            strongSelf.allLogArray.append(log)
            strongSelf.notifyLogArrayChange()
            
            if strongSelf.logMatchesCurrentFilter(log: log) {
                strongSelf.batchInsertFilteredLog(log: log)
            }
            
            
            if log.level == .Error {
                strongSelf.errorCount += 1
            } else if log.level == .Warning {
                strongSelf.warningCount += 1
            }
        }
    }
    
    public func clearAllLogs() {
        dispatch_main_async_safe { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.allLogArray.removeAll()
            strongSelf.reloadFilteredLogArray()
            strongSelf.notifyLogArrayChange()
        }
    }
    
    // MARK: - private functions
    
    private func reloadFilteredLogArray() {
        filteredLogArray = allLogArray.filter{ logMatchesCurrentFilter(log: $0) }
    }
    
    private func logMatchesCurrentFilter(log:JLConsoleLogModel) -> Bool {
        if filterLevels.count > 0 && filterLevels.contains(log.level) {
            return false
        }
        
        if filterCategories.count > 0 && log.category.count > 0 && filterCategories.contains(log.category) {
            return false
        }
        
        if filterKeywords.count > 0 {
            let info = log.info
            let result = filterKeywords.filter{ NSString(string: info).range(of: $0, options: .caseInsensitive).location != NSNotFound }
            if result.count == 0 {
                return false
            }
        }
        
        return true
    }
    
    private func batchInsertFilteredLog(log:JLConsoleLogModel) {
        if pendingFilteredLogArray.count > 0 {
            self.perform(#selector(insertPendingFilteredLogItems), with: nil, afterDelay: 0.3, inModes: [RunLoop.Mode.common])
        }
        
        pendingFilteredLogArray.append(log)
    }
    
    @objc private func insertPendingFilteredLogItems() {
        let matchedLogs = pendingFilteredLogArray.filter{ logMatchesCurrentFilter(log: $0) }
        filteredLogArray.append(contentsOf: matchedLogs)
        pendingFilteredLogArray.removeAll()
    }
    
    
    
    // MARK: - notification
    
    private func notifyLogArrayChange(){
        JLConsoleLogManager.consoleLogNotificationCenter.post(name: AllLogsDidChangeNotification, object: self)
    }
    
    private func notifyFilterSettingChange() {
        JLConsoleLogManager.consoleLogNotificationCenter.post(name: FilterSettingChangeNotification, object: self)
    }
    
    private func notifyWarningChange() {
        JLConsoleLogManager.consoleLogNotificationCenter.post(name: WarningCountChangeNotification, object: self)
    }
    
    private func notifyErrorChange() {
        JLConsoleLogManager.consoleLogNotificationCenter.post(name: ErrorCountChangeNotification, object: self)
    }
}
