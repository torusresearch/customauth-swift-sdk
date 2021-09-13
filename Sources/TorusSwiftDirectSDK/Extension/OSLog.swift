//
// Created by Michael Lee on 13/9/2021.
//

import os.log
import Foundation

public let subsystem = Bundle.main.bundleIdentifier ?? "com.torus.TorusSwiftDirectSDK"

public struct TDSDKLogger {
    static let inactiveLog = OSLog.disabled
    static let core = OSLog(subsystem: subsystem, category: "core")
}

@available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
func log(_ message: StaticString, dso: UnsafeRawPointer? = #dsohandle, log: OSLog = .default, type: OSLogType = .default, _ args: CVarArg...){
    var logCheck: OSLog { tsSdkLogType.rawValue <= type.rawValue ? log : TDSDKLogger.inactiveLog}
    os_log(message, dso: dso, log: logCheck, type: type, args)
}