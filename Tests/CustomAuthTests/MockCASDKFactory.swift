//
//  File.swift
//
//
//  Created by Shubham on 31/7/21.
//

import CustomAuth
import FetchNodeDetails
import Foundation
import OSLog
import TorusUtils
import CommonSources
public class MockFactory: CASDKFactoryProtocol {
    init() {}

    public func createTorusUtils(loglevel: OSLogType, urlSession: URLSession, enableOneKey: Bool, network: TorusNetwork) -> AbstractTorusUtils {
        MockTorusUtils()
    }
}
