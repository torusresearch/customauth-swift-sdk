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
    public func trace(_ message: Any..., file: String = #file, function: String = #function, line: UInt = #line) {
        if self.logLevel <= .trace{
            print("[TRACE] \((file as NSString).lastPathComponent) [\(line)]:", terminator: " ")
            _ = message.map{ return print($0, terminator: ", ")}
            print("\n")
        }
    }
    
    public func debug(_ message: Any..., file: String = #file, function: String = #function, line: UInt = #line) {
        if self.logLevel <= .debug{
            print("[DEBUG]\((file as NSString).lastPathComponent) [\(line)]:", terminator: " ")
            _ = message.map{ print($0, terminator: ", ")}
            print("\n")
        }
    }
    
    public func info(_ message: Any..., file: String = #file, function: String = #function, line: UInt = #line) {
        if self.logLevel <= .info{
            print("[INFO] \((file as NSString).lastPathComponent) [\(line)]:", terminator: " ")
            _ = message.map{ print($0, terminator: ", ")}
            print("\n")
        }
    }
    
    public func warning(_ message: Any..., file: String = #file, function: String = #function, line: UInt = #line) {
        if self.logLevel <= .warning{
            print("[WARNING] \((file as NSString).lastPathComponent) [\(line)]:", terminator: " ")
            _ = message.map{ print($0, terminator: ", ")}
            print("\n")
        }
    }
    
    public func error(_ message: Any..., file: String = #file, function: String = #function, line: UInt = #line) {
        if self.logLevel <= .error{
            print("[ERROR] \((file as NSString).lastPathComponent) [\(line)]:", terminator: " ")
            _ = message.map{ print($0, terminator: ", ")}
            print("\n")
        }
    }
    
}
