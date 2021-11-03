//
//  File.swift
//  
//
//  Created by Michael Lee on 31/10/2021.
//

import XCTest
import PromiseKit
import Foundation
import TorusUtils
import FetchNodeDetails
import OSLog
import TorusSwiftDirectSDK

@available(iOS 13.0, *)
final class StubURLProtocolTests: XCTestCase {
    func testStubURLProtocol() {
        let expectation = XCTestExpectation(description: "getTorusKey using stubbed URLSession should work")
        let sessionConfiguration = URLSessionConfiguration.ephemeral
        sessionConfiguration.protocolClasses = [StubURLProtocol.self]
        let session = URLSession.init(configuration: sessionConfiguration)
        
        
        
        wait(for: [expectation1, expectation2], timeout: 5)
    }
}

public class StubMockTorusUtils: TorusUtils {
    override open func getTimestamp() -> TimeInterval {
        
        let ret = 0.0
        print("[StubMockTorusUtils] getTimeStamp(): ", ret)
        return ret
    }
    override open func generatePrivateKeyData() -> Data? {
        // empty bytes
//        let ret = Data(count: 32)
        
        let ret = Data(base64Encoded: "FBz7bssmbsV6jBWoOJpkVOu14+6/Xgyt1pxTycODG08=")
        
        print("[StubMockTorusUtils] generatePrivateKeyData(): ", ret!.bytes.toBase64())
        return ret
    }
}

public class StubMockTDSDKFactory: TDSDKFactoryProtocol {
    public func createFetchNodeDetails(network: EthereumNetwork, urlSession: URLSession) -> FetchNodeDetails {
        let net = network == .MAINNET ? "0x638646503746d5456209e33a2ff5e3226d698bea" : "0x4023d2a0D330bF11426B12C6144Cfb96B7fa6183"
        return FetchNodeDetails(proxyAddress: net, network: network)
    }
    
    public func createTorusUtils(nodePubKeys: Array<TorusNodePub> = [], loglevel: OSLogType, urlSession: URLSession) -> AbstractTorusUtils {
        return StubMockTorusUtils(nodePubKeys: nodePubKeys, loglevel: loglevel)
    }
    
    public init(){
        
    }
    
    
}
