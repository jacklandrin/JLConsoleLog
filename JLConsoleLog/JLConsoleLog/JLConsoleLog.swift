//
//  JLConsoleLog.swift
//  JLConsoleLog
//
//  Created by jack on 2020/4/25.
//  Copyright © 2020 jack. All rights reserved.
//

import Foundation
import os.log

public typealias JLConsoleLogCategory = String


public enum JLConsoleLogLevel: String {
    case Verbose = "🍔VERBOSE🐌"
    case Debug = "🔍DEBUG🐞"
    case Info = "📔INFO🦄"
    case Warning = "⚠️WARNING🙊"
    case Error = "⚡️ERROR🙈"
}

public struct JLLogOptions {
    public let level: JLConsoleLogLevel
    public let category: JLConsoleLogCategory
    public let contextData: Dictionary<String, Any>
    public let info: String
}

public func JLLog(options:JLLogOptions) {
    JLConsoleController.shared.logManager.append(log: JLConsoleLogModel(options: options))
}

@available(OSX 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
private func convertLogType(level: JLConsoleLogLevel) -> OSLogType {
    switch level {
    case .Verbose:
        return .default
    case .Debug:
        return .debug
    case .Info:
        return .info
    case .Warning:
        return .default
    case .Error:
        return .error
    }
}

private func _JLLevelLog(level:JLConsoleLogLevel, category:JLConsoleLogCategory, hasFollowingAction:Bool, needPrint:Bool, contextData:Dictionary<String,Any>, formats: [String]) {
    guard JLConsoleController.shared.logEnabled else {
        return
    }
        
    let formattedString = formats.joined(separator: "\r\n")
    let options = JLLogOptions(level: level, category: category, contextData: contextData, info: formattedString)
    JLLog(options: options)
    #if DEBUG
    if needPrint {
        if #available(iOS 10.0, *) {
            let logger = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "com.JLConsoleLog", category: category)
            os_log("%@ - %d", log: logger, type: convertLogType(level: level), contextData, formattedString)
        } else {
            print("\(level)  \(category)  \(contextData) \(formattedString)")
        }
    }
    #endif
    if hasFollowingAction {
        JLConsoleController.shared.followingAction?(options)
    }
}

public func JLLevelLog(level: JLConsoleLogLevel, category: JLConsoleLogCategory, hasFollowingAction:Bool = false, needPrint:Bool = false, contextData:Dictionary<String,Any> , formats: String...) {
    _JLLevelLog(level: level, category: category, hasFollowingAction: hasFollowingAction, needPrint: needPrint, contextData: contextData, formats: formats)
}

public func JLInfoLog( category: JLConsoleLogCategory, hasFollowingAction:Bool = false, needPrint:Bool = false, contextData:Dictionary<String,Any> , formats: String...) {
    _JLLevelLog(level: .Info, category: category, hasFollowingAction: hasFollowingAction, needPrint: needPrint, contextData: contextData, formats: formats)
}
 
public func JLVerboseLog( category: JLConsoleLogCategory, hasFollowingAction:Bool = false, needPrint:Bool = false, contextData:Dictionary<String,Any> , formats: String...) {
    _JLLevelLog(level: .Verbose, category: category, hasFollowingAction: hasFollowingAction, needPrint: needPrint, contextData: contextData, formats: formats)
}

public func JLWarningLog( category: JLConsoleLogCategory, hasFollowingAction:Bool = false, needPrint:Bool = false, contextData:Dictionary<String,Any> , formats: String...) {
    _JLLevelLog(level: .Warning, category: category, hasFollowingAction: hasFollowingAction, needPrint: needPrint, contextData: contextData, formats: formats)
}

public func JLErrorLog( category: JLConsoleLogCategory, hasFollowingAction:Bool = false, needPrint:Bool = false, contextData:Dictionary<String,Any> , formats: String...) {
    _JLLevelLog(level: .Error, category: category, hasFollowingAction: hasFollowingAction, needPrint: needPrint, contextData: contextData, formats: formats)
}

public func JLDebugLog( category: JLConsoleLogCategory, hasFollowingAction:Bool = false, needPrint:Bool = false, contextData:Dictionary<String,Any> , formats: String...) {
    _JLLevelLog(level: .Debug, category: category, hasFollowingAction: hasFollowingAction, needPrint: needPrint, contextData: contextData, formats: formats)
}

public func JLRegister(newCategory:JLConsoleLogCategory) {
    JLConsoleController.shared.register(newCategory: newCategory)
}
