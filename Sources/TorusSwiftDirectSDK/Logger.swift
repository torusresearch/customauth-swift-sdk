//
//  Logger.swift
//

import Foundation

public struct TorusLogger{
        
    public let label: String
    public var logLevel: Level

    internal init(label: String, level: Level) {
        self.label = label
        self.logLevel = level
    }
    
    public enum Level: String {
        case trace
        case debug
        case info
        case warning
        case error
        case none
        
        internal var naturalIntegralValue: Int {
            switch self {
            case .trace:
                return 0
            case .debug:
                return 1
            case .info:
                return 2
            case .warning:
                return 3
            case .error:
                return 4
            case .none:
                return 5
            }
        }
        
    }
}

extension TorusLogger.Level: Comparable {
    public static func < (lhs: TorusLogger.Level, rhs: TorusLogger.Level) -> Bool {
        return lhs.naturalIntegralValue < rhs.naturalIntegralValue
    }
}

extension TorusLogger{
    public func trace<T>(_ message: @autoclosure () -> T,
                      file: String = #file, function: String = #function, line: UInt = #line) {
        print("[TRACE] \((file as NSString).lastPathComponent) [\(line)]: \(message())")
    }
    
    public func debug<T>(_ message: @autoclosure () -> T,
                      file: String = #file, function: String = #function, line: UInt = #line) {
        print("[DEBUG] \((file as NSString).lastPathComponent) [\(line)]: \(message())")
    }
    
    public func info<T>(_ message: @autoclosure () -> T,
                      file: String = #file, function: String = #function, line: UInt = #line) {
        print("[INFO] \((file as NSString).lastPathComponent) [\(line)]: \(message())")
    }
    
    public func warning<T>(_ message: @autoclosure () -> T,
                      file: String = #file, function: String = #function, line: UInt = #line) {
        print("[WARNING] \((file as NSString).lastPathComponent) [\(line)]: \(message())")
    }
    
    public func error<T>(_ message: @autoclosure () -> T,
                      file: String = #file, function: String = #function, line: UInt = #line) {
        print("[ERROR] \((file as NSString).lastPathComponent) [\(line)]: \(message())")
    }

}
