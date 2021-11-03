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
        let urlSession = URLSession.init(configuration: sessionConfiguration)
        let tdsdk = TorusSwiftDirectSDK(aggregateVerifierType: .singleLogin, aggregateVerifierName: "torus-direct-mock-ios", subVerifierDetails: [], factory: StubMockTDSDKFactory(), network: .ROPSTEN, loglevel: .debug, urlSession: urlSession)
        tdsdk.getTorusKey(verifier: "torus-direct-mock-ios", verifierId: "michael@tor.us", idToken: "eyJhbGciOiJSUzI1NiIsImtpZCI6ImFkZDhjMGVlNjIzOTU0NGFmNTNmOTM3MTJhNTdiMmUyNmY5NDMzNTIiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJhenAiOiI2MzYxOTk0NjUyNDItZmQ3dWp0b3JwdnZ1ZHRzbDN1M2V2OTBuaWplY3RmcW0uYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJhdWQiOiI2MzYxOTk0NjUyNDItZmQ3dWp0b3JwdnZ1ZHRzbDN1M2V2OTBuaWplY3RmcW0uYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJzdWIiOiIxMDkxMTE5NTM4NTYwMzE3OTk2MzkiLCJoZCI6InRvci51cyIsImVtYWlsIjoibWljaGFlbEB0b3IudXMiLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiYXRfaGFzaCI6InRUNDhSck1vdGFFbi1UN3dzc2U3QnciLCJub25jZSI6InZSU2tPZWwyQTkiLCJuYW1lIjoiTWljaGFlbCBMZWUiLCJwaWN0dXJlIjoiaHR0cHM6Ly9saDMuZ29vZ2xldXNlcmNvbnRlbnQuY29tL2EvQUFUWEFKd3NCYjk4Z1NZalZObEJCQWhYSmp2cU5PdzJHRFNlVGYwSTZTSmg9czk2LWMiLCJnaXZlbl9uYW1lIjoiTWljaGFlbCIsImZhbWlseV9uYW1lIjoiTGVlIiwibG9jYWxlIjoiZW4iLCJpYXQiOjE2MzQ0NjgyNDksImV4cCI6MTYzNDQ3MTg0OX0.XGu1tm_OqlSrc5BMDMzOrlhxLZo1YnpCUT0_j2U1mQt86nJzf_Hp85JfapZj2QeeUz91H6-Ei8FR1i4ICEfjMcoZOW1Azc89qUNfUgWeyjqZ7wCHSsbHAwabE74RFAS9YAja8_ynUvCARfDEtoqcreNgmbw3ZntzAqpuuNBXYfbr87kMvu_wZ7fWjLKM91CvuXytQBwtieTyjAFnTXmEL60Pdu-JSQfHCbS5H39ZHlnYxEO6qztIjvbnQokhjHDGc4PMCx0wfzrEet1ojNOCnbfmaYE5NQudquzQNZtqZfn8f4B-sQhECElnOXagHlafWO5RayS0dCb1mTfr8orcCA", userData: [:]).done{ data in
            print("get torus key success: ", data)
            expectation.fulfill()
        }.catch{ err in
            XCTFail(err.localizedDescription)
        }
        
        wait(for: [expectation], timeout: 12000)
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
        return FetchNodeDetails(proxyAddress: net, network: network, urlSession: urlSession)
    }
    
    public func createTorusUtils(nodePubKeys: Array<TorusNodePub> = [], loglevel: OSLogType, urlSession: URLSession) -> AbstractTorusUtils {
        return StubMockTorusUtils(nodePubKeys: nodePubKeys, loglevel: loglevel, urlSession: urlSession)
    }
    
    public init(){
        
    }
    
    
}
