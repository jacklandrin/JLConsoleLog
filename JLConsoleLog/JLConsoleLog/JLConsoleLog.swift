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


/// These log levels are supported
public enum JLConsoleLogLevel: String {
    /// for verbose information or some logs needed to trace
    case Verbose = "🍔VERBOSE🐌"
    
    /// for some information needed to debug
    case Debug = "🔍DEBUG🐞"
    
    /// testify programme running as your expection
    case Info = "📔INFO🦄"
    
    /// something you should notice
    case Notice = "📌NOTICE🐍"
    
    /// a fatal issue, application can't run in the normal way
    case Critical = "👎🏻CRITICAL☠️"
    
    /// something happens by accident
    case Warning = "⚠️WARNING🙊"
    
    /// a serious error happens, some feathers of application can't run
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
    case .Notice:
        return .default
    case .Critical:
        return .fault
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


/// main log function
/// - Parameters:
///   - level: a log level, levels include verbose, info, debug, warning and error.
///   - category: a business category definded by users.
///   - hasFollowingAction: whether need a following action after logging.
///   - needPrint: whether print a log in XCode log.
///   - contextData: a key : value format data about log information.
///   - formats: this is a variadic parameter, the first value will show on the cell.
public func JLLevelLog(level: JLConsoleLogLevel, category: JLConsoleLogCategory, hasFollowingAction:Bool = false, needPrint:Bool = false, contextData:Dictionary<String,Any> , formats: String...) {
    _JLLevelLog(level: level, category: category, hasFollowingAction: hasFollowingAction, needPrint: needPrint, contextData: contextData, formats: formats)
}


/// convenient function for Info level
/// - Parameters:
///      see JLLevelLog
public func JLInfoLog( category: JLConsoleLogCategory, hasFollowingAction:Bool = false, needPrint:Bool = false, contextData:Dictionary<String,Any> , formats: String...) {
    _JLLevelLog(level: .Info, category: category, hasFollowingAction: hasFollowingAction, needPrint: needPrint, contextData: contextData, formats: formats)
}

/// convenient function for Verbose level
/// - Parameters:
///      see JLLevelLog
public func JLVerboseLog( category: JLConsoleLogCategory, hasFollowingAction:Bool = false, needPrint:Bool = false, contextData:Dictionary<String,Any> , formats: String...) {
    _JLLevelLog(level: .Verbose, category: category, hasFollowingAction: hasFollowingAction, needPrint: needPrint, contextData: contextData, formats: formats)
}

/// convenient function for Warning level
/// - Parameters:
///      see JLLevelLog
public func JLWarningLog( category: JLConsoleLogCategory, hasFollowingAction:Bool = false, needPrint:Bool = false, contextData:Dictionary<String,Any> , formats: String...) {
    _JLLevelLog(level: .Warning, category: category, hasFollowingAction: hasFollowingAction, needPrint: needPrint, contextData: contextData, formats: formats)
}


/// convenient function for Error level
/// - Parameters:
///      see JLLevelLog
public func JLErrorLog( category: JLConsoleLogCategory, hasFollowingAction:Bool = false, needPrint:Bool = false, contextData:Dictionary<String,Any> , formats: String...) {
    _JLLevelLog(level: .Error, category: category, hasFollowingAction: hasFollowingAction, needPrint: needPrint, contextData: contextData, formats: formats)
}

/// convenient function for Debug level
/// - Parameters:
///      see JLLevelLog
public func JLDebugLog( category: JLConsoleLogCategory, hasFollowingAction:Bool = false, needPrint:Bool = false, contextData:Dictionary<String,Any> , formats: String...) {
    _JLLevelLog(level: .Debug, category: category, hasFollowingAction: hasFollowingAction, needPrint: needPrint, contextData: contextData, formats: formats)
}

/// convenient function for Notice level
/// - Parameters:
///      see JLLevelLog
public func JLNoticeLog( category: JLConsoleLogCategory, hasFollowingAction:Bool = false, needPrint:Bool = false, contextData:Dictionary<String,Any> , formats: String...) {
    _JLLevelLog(level: .Notice, category: category, hasFollowingAction: hasFollowingAction, needPrint: needPrint, contextData: contextData, formats: formats)
}

/// convenient function for Critical level
/// - Parameters:
///      see JLLevelLog
public func JLCriticalLog( category: JLConsoleLogCategory, hasFollowingAction:Bool = false, needPrint:Bool = false, contextData:Dictionary<String,Any> , formats: String...) {
    _JLLevelLog(level: .Critical, category: category, hasFollowingAction: hasFollowingAction, needPrint: needPrint, contextData: contextData, formats: formats)
}

/// register a new category in a set for filterring
/// - Parameter newCategory: a business category
public func JLRegister(newCategory:JLConsoleLogCategory) {
    JLConsoleController.shared.register(newCategory: newCategory)
}
