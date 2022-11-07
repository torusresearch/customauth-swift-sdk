//
//  File.swift
//
//
//  Created by Michael Lee on 31/10/2021.
//

import CustomAuth
import FetchNodeDetails
import Foundation
import OSLog
import PromiseKit
import TorusUtils
import XCTest

final class StubURLProtocolTests: XCTestCase {
//    func testStubURLProtocol() {
//        let expectation = XCTestExpectation(description: "getTorusKey using stubbed URLSession should work")
//        let sessionConfiguration =c URLSessionConfiguration.ephemeral
//        sessionConfiguration.protocolClasses = [StubURLProtocol.self]
//        let urlSession = URLSession(configuration: sessionConfiguration)
//        let tdsdk = CustomAuth(aggregateVerifierType: .singleLogin, aggregateVerifierName: "torus-direct-mock-ios", subVerifierDetails: [], factory: StubMockCASDKFactory(), network: .ROPSTEN, loglevel: .debug, urlSession: urlSession)
//        tdsdk.getTorusKey(verifier: "torus-direct-mock-ios", verifierId: "michael@tor.us", idToken: "eyJhbGciOiJSUzI1NiIsImtpZCI6ImFkZDhjMGVlNjIzOTU0NGFmNTNmOTM3MTJhNTdiMmUyNmY5NDMzNTIiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJhenAiOiI2MzYxOTk0NjUyNDItZmQ3dWp0b3JwdnZ1ZHRzbDN1M2V2OTBuaWplY3RmcW0uYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJhdWQiOiI2MzYxOTk0NjUyNDItZmQ3dWp0b3JwdnZ1ZHRzbDN1M2V2OTBuaWplY3RmcW0uYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJzdWIiOiIxMDkxMTE5NTM4NTYwMzE3OTk2MzkiLCJoZCI6InRvci51cyIsImVtYWlsIjoibWljaGFlbEB0b3IudXMiLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiYXRfaGFzaCI6InRUNDhSck1vdGFFbi1UN3dzc2U3QnciLCJub25jZSI6InZSU2tPZWwyQTkiLCJuYW1lIjoiTWljaGFlbCBMZWUiLCJwaWN0dXJlIjoiaHR0cHM6Ly9saDMuZ29vZ2xldXNlcmNvbnRlbnQuY29tL2EvQUFUWEFKd3NCYjk4Z1NZalZObEJCQWhYSmp2cU5PdzJHRFNlVGYwSTZTSmg9czk2LWMiLCJnaXZlbl9uYW1lIjoiTWljaGFlbCIsImZhbWlseV9uYW1lIjoiTGVlIiwibG9jYWxlIjoiZW4iLCJpYXQiOjE2MzQ0NjgyNDksImV4cCI6MTYzNDQ3MTg0OX0.XGu1tm_OqlSrc5BMDMzOrlhxLZo1YnpCUT0_j2U1mQt86nJzf_Hp85JfapZj2QeeUz91H6-Ei8FR1i4ICEfjMcoZOW1Azc89qUNfUgWeyjqZ7wCHSsbHAwabE74RFAS9YAja8_ynUvCARfDEtoqcreNgmbw3ZntzAqpuuNBXYfbr87kMvu_wZ7fWjLKM91CvuXytQBwtieTyjAFnTXmEL60Pdu-JSQfHCbS5H39ZHlnYxEO6qztIjvbnQokhjHDGc4PMCx0wfzrEet1ojNOCnbfmaYE5NQudquzQNZtqZfn8f4B-sQhECElnOXagHlafWO5RayS0dCb1mTfr8orcCA", userData: [:]).done { data in
//            XCTAssertEqual(data["publicAddress"] as! String, "0x22f2Ce611cE0d0ff4DA661d3a4C4B7A60B2b13F8")
//            XCTAssertEqual(data["privateKey"] as! String, "495b9a126c0c703caeaa5c561692d6778952c455789b0a2ba04312cfdc2e1bb9")
//            expectation.fulfill()
//        }.catch { err in
//            XCTFail(err.localizedDescription)
//        }
//
//        wait(for: [expectation], timeout: 12000)
//    }
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

public class StubMockCASDKFactory: CASDKFactoryProtocol {
    public func createFetchNodeDetails(network: EthereumNetworkFND, urlSession: URLSession,networkUrl:String? = nil) -> FetchNodeDetails {
        let net = network == .MAINNET ? "0xf20336e16B5182637f09821c27BDe29b0AFcfe80" : "0x6258c9d6c12ed3edda59a1a6527e469517744aa7"
        return FetchNodeDetails(proxyAddress: net, network: network, urlSession: urlSession)
    }

    public func createTorusUtils(loglevel: OSLogType, urlSession: URLSession,enableOneKey:Bool,network:EthereumNetworkFND) -> AbstractTorusUtils {
        let allowHost = network.signerMap.appending("/api/allow")
        let signerHost = network.signerMap.appending("/api/sign")
        return StubMockTorusUtils(loglevel: loglevel, urlSession: urlSession,enableOneKey:enableOneKey,signerHost: signerHost,allowHost: allowHost)
    }

    public init() {
    }
}
