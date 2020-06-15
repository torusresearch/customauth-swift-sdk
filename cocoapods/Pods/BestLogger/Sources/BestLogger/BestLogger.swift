//
//  BestLogger.swift
//
// Author - Shubham Rathi 15/06/2020

import Foundation

/// A `Logger` is the a struc in `BestLogger`. You can use its method to print various variables depending on set `logLevel`
/// corresponding to a log level.
///
/// The most basic usage of a `BestLogger` is
///
///     logger.info("Hello World!")
///

public struct BestLogger{
    
    /// Logger identifier
    public let label: String
    
    /// Log level identifier
    public var logLevel: Level
    
    /// Construct a `BestLogger` given a `label`  and level `logLevel`
    ///
    /// The `label` should identify the creator of the `Logger`. This can be an application, a sub-system, or even
    /// a datatype.
    ///
    /// - parameters:
    ///     - label: An identifier for the creator of a `Logger`.
    ///     - logLevel: A Identifier for log level
    public init(label: String, level: Level) {
        self.label = label
        self.logLevel = level
    }
    
    /// The log level.
    ///
    /// Log levels are ordered by their severity, with `.trace` being the least severe and
    /// `.none` being nothing.
    public enum Level: Int, Comparable {
        case trace = 0
        case debug
        case info
        case warning
        case error
        case none
        
        public static func < (a: Level, b: Level) -> Bool {
            return a.rawValue < b.rawValue
        }
    }
    
}

extension BestLogger{
    /// Log a message passing with the `Logger.Level.trace` log level.
    ///
    /// will be logged if  `.trace` is at least as severe as the `Logger`'s `logLevel`
    ///
    /// - parameters:
    ///    - message: The message to be logged, pass multiple vairables to be logged. e.g, .trace(1,2,3)
    ///    - metadata: One-off metadata to attach to this log message
    ///    - file: The file this log message originates from
    ///    - function: The function this log message originates from
    ///    - line: The line this log message originates from
    @inlinable
    public func trace(_ message: Any..., file: String = #file, function: String = #function, line: UInt = #line) {
        if self.logLevel <= .trace{
            print("[TRACE] \((file as NSString).lastPathComponent) [\(line)]:", terminator: " ")
            _ = message.map{ return print($0, terminator: " ")}
            print("\n")
        }
    }
    
    
    /// Log a message passing with the `Logger.Level.debug` log level.
    ///
    /// will be logged if  `.debug` is at least as severe as the `Logger`'s `logLevel`
    ///
    /// - parameters:
    ///    - message: The message to be logged, pass multiple vairables to be logged. e.g, .debug(1,2,3)
    ///    - metadata: One-off metadata to attach to this log message
    ///    - file: The file this log message originates from
    ///    - function: The function this log message originates from
    ///    - line: The line this log message originates from
    public func debug(_ message: Any..., file: String = #file, function: String = #function, line: UInt = #line) {
        if self.logLevel <= .debug{
            print("[DEBUG] \((file as NSString).lastPathComponent) [\(line)]:", terminator: " ")
            _ = message.map{ print($0, terminator: " ")}
            print("\n")
        }
    }
    
    /// Log a message passing with the `Logger.Level.info` log level.
    ///
    /// will be logged if  `.info` is at least as severe as the `Logger`'s `logLevel`
    ///
    /// - parameters:
    ///    - message: The message to be logged, pass multiple vairables to be logged. e.g, .info(1,2,3)
    ///    - metadata: One-off metadata to attach to this log message
    ///    - file: The file this log message originates from
    ///    - function: The function this log message originates from
    ///    - line: The line this log message originates from
    public func info(_ message: Any..., file: String = #file, function: String = #function, line: UInt = #line) {
        if self.logLevel <= .info{
            print("[INFO] \((file as NSString).lastPathComponent) [\(line)]:", terminator: " ")
            _ = message.map{ print($0, terminator: " ")}
            print("\n")
        }
    }
    
    /// Log a message passing with the `Logger.Level.warning` log level.
    ///
    /// will be logged if  `.warning` is at least as severe as the `Logger`'s `logLevel`
    ///
    /// - parameters:
    ///    - message: The message to be logged, pass multiple vairables to be logged. e.g, .trace(1,2,3)
    ///    - metadata: One-off metadata to attach to this log message
    ///    - file: The file this log message originates from
    ///    - function: The function this log message originates from
    ///    - line: The line this log message originates from
    public func warning(_ message: Any..., file: String = #file, function: String = #function, line: UInt = #line) {
        if self.logLevel <= .warning{
            print("[WARNING] \((file as NSString).lastPathComponent) [\(line)]:", terminator: " ")
            _ = message.map{ print($0, terminator: " ")}
            print("\n")
        }
    }
    
    /// Log a message passing with the `Logger.Level.error` log level.
    ///
    /// will be logged if  `.error` is at least as severe as the `Logger`'s `logLevel`
    ///
    /// - parameters:
    ///    - message: The message to be logged, pass multiple vairables to be logged. e.g, .error(1,2,3)
    ///    - metadata: One-off metadata to attach to this log message
    ///    - file: The file this log message originates from
    ///    - function: The function this log message originates from
    ///    - line: The line this log message originates from
    public func error(_ message: Any..., file: String = #file, function: String = #function, line: UInt = #line) {
        if self.logLevel <= .error{
            print("[ERROR] \((file as NSString).lastPathComponent) [\(line)]:", terminator: " ")
            _ = message.map{ print($0, terminator: " ")}
            print("\n")
        }
    }
    
}
