//
// Created by Michael Lee on 13/9/2021.
//

import os.log
import Foundation

public let subsystem = Bundle.main.bundleIdentifier ?? "com.torus.TorusSwiftDirectSDK"
//
//typealias OriginalOSLogFunction = (_ message: StaticString, _ dso: UnsafeRawPointer? , _ log: OSLog , _ type: OSLogType , _ args: CVarArg...) -> Void
//
//typealias ConvertedOSLogFunction = (_ message: StaticString, _ dso: UnsafeRawPointer? , _ log: OSLog , _ type: OSLogType , _ args: [CVarArg]) -> Void
//
//let os_logv = unsafeBitCast(os_log as OriginalOSLogFunction, to: ConvertedOSLogFunction.self)

public struct TDSDKLogger {
    static let inactiveLog = OSLog.disabled
    static let core = OSLog(subsystem: subsystem, category: "core")
}

@available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
func getTorusLogger(log: OSLog = .default, type: OSLogType = .default) -> OSLog {
    var logCheck: OSLog { tsSdkLogType.rawValue <= type.rawValue ? log : TDSDKLogger.inactiveLog}
    return logCheck
}

//@available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
//func log(_ message: StaticString, dso: UnsafeRawPointer? = #dsohandle, log: OSLog = .default, type: OSLogType = .default, _ args: CVarArg...){
//    var logCheck: OSLog { tsSdkLogType.rawValue <= type.rawValue ? log : TDSDKLogger.inactiveLog}
//    os_logv(message, dso, logCheck, type, args)
//}
