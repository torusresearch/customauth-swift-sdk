//
//  Logger.swift
//


import Foundation

public enum Loglevel: Int {
    // basic: Development
    case trace = 0
    // medium: Debug
    case warn
    // highest: Production
    case error
    // Show none: Production
    case none
}

public class TorusLogger{
    
}

public protocol LoggerProtocol {
    
    var level: Loglevel { get }
    
    /// basic
    func trace<T>(_ message: @autoclosure () -> T, filename: String, line: Int, function: String)
    
    /// medium
    func warn<T>(_ message: @autoclosure () -> T, filename: String, line: Int, function: String)
    
    /// error
    func error<T>(_ message: @autoclosure () -> T, filename: String, line: Int, function: String)
    
    /// No logs
    // func none<T>(_ message: @autoclosure () -> T, filename: String, line: Int, function: String)
}

extension LoggerProtocol {
    
    public func trace<T>(_ message: @autoclosure () -> T, filename: String = #file, line: Int = #line, function: String = #function) {
        let logLevel = Loglevel.trace
        // deduce based on the current log level vs. globally set level, to print such log or not
        if level.rawValue >= logLevel.rawValue {
            print("[TRACE] \((filename as NSString).lastPathComponent) [\(line)]: \(message())")
        }
    }
    
    public func warn<T>(_ message: @autoclosure () -> T, filename: String = #file, line: Int = #line, function: String = #function) {
        let logLevel = Loglevel.warn
        if level.rawValue >= logLevel.rawValue {
            print("[WARN] \(self) = \((filename as NSString).lastPathComponent) [\(line)]: \(message())")
        }
    }
    
    public func error<T>(_ message: @autoclosure () -> T, filename: String = #file, line: Int = #line, function: String = #function) {
        let logLevel = Loglevel.error
        if level.rawValue >= logLevel.rawValue {
            print("[ERROR] \((filename as NSString).lastPathComponent) [\(line)]: \(message())")
        }
    }
}

public struct DebugLogger: LoggerProtocol {
    public let level: Loglevel
    init(_ level: Loglevel) {
        self.level = level
    }
}
