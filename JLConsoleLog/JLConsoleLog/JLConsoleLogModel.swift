//
//  JLConsoleLogModel.swift
//  JLConsoleLog
//
//  Created by jack on 2020/4/26.
//  Copyright © 2020 jack. All rights reserved.
//

import Foundation

class JLConsoleLogModel: NSObject {
    public internal(set) var info: String = ""
    public internal(set) var invokingInfo: String = ""
    public internal(set) var level: JLConsoleLogLevel = .Verbose
    public internal(set) var category: String = ""
    public internal(set) var time: TimeInterval = 0.0
    
    
    
    convenience init(options:JLLogOptions) {
        self.init()
        self.info = options.info
        self.category = options.category
        self.level = options.level
        self.category = options.category
        self.invokingInfo = convertContextData(options.contextData)
    }
    
    func convertContextData(_ contextData: Dictionary<String,Any>) -> String {
        var decoded = ""
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: contextData, options: [])
            decoded = String(data: jsonData, encoding: .utf8)!
        } catch {
            print(error)
        }
        
        return decoded
    }
    
}
