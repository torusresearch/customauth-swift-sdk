@testable import CustomAuth
import TorusUtils
import UIKit
import XCTest

@available(iOS 11.0, *)
final class MockSDKTest: XCTestCase {
    func testGetTorusKey() {
        let expectation = XCTestExpectation(description: "getTorusKey should correctly proxy input and output to/from TorusUtils")

        let expectedPrivateKey = fakeData.generatePrivateKey()
        let expectedPublicAddress = fakeData.generatePublicKey()
        let expectedVerifier = fakeData.generateVerifier()
        let expectedVerfierId = fakeData.generateRandomEmail(of: 6)

        let subVerifier = [SubVerifierDetails(loginProvider: .jwt, clientId: fakeData.generateVerifier(), verifierName: expectedVerifier, redirectURL: fakeData.generateVerifier())]
        let factory = MockFactory()

        let CustomAuth = CustomAuth(aggregateVerifierType: .singleLogin, aggregateVerifierName: expectedVerifier, subVerifierDetails: subVerifier, factory: factory)
        var mockTorusUtils = CustomAuth.torusUtils as! MockAbstractTorusUtils

        // Set Mock data
        mockTorusUtils.retrieveShares_output["privateKey"] = expectedPrivateKey
        mockTorusUtils.retrieveShares_output["publicAddress"] = expectedPublicAddress

        CustomAuth.getTorusKey(verifier: expectedVerifier, verifierId: expectedVerfierId, idToken: fakeData.generateVerifier())
            .done { data in
                let mockTorusUtils = CustomAuth.torusUtils as! MockAbstractTorusUtils
                XCTAssertEqual(mockTorusUtils.retrieveShares_input["endpoints"] as? [String], CustomAuth.endpoints)
                XCTAssertEqual(mockTorusUtils.retrieveShares_input["verifierIdentifier"] as? String, expectedVerifier)
                XCTAssertEqual(mockTorusUtils.retrieveShares_input["verifierId"] as? String, expectedVerfierId)
                XCTAssertEqual(data["privateKey"] as? String, expectedPrivateKey)
                XCTAssertEqual(data["publicAddress"] as? String, expectedPublicAddress)
            }.catch { err in
                XCTFail(err.localizedDescription)
            }.finally {
                expectation.fulfill()
            }
        wait(for: [expectation], timeout: 5)
    }

    func testGetAggregateTorusKey() {
        let expectation = XCTestExpectation(description: "getAggregateTorusKey should correctly proxy input and output to/from TorusUtils")

        let expectedPrivateKey = fakeData.generatePrivateKey()
        let expectedPublicAddress = fakeData.generatePublicKey()
        let expectedVerifier = fakeData.generateVerifier()
        let expectedVerfierId = fakeData.generateRandomEmail(of: 6)

        let subVerifier = [SubVerifierDetails(loginProvider: .jwt, clientId: fakeData.generateVerifier(), verifierName: expectedVerifier, redirectURL: fakeData.generateVerifier())]
        let factory = MockFactory()

        let CustomAuth = CustomAuth(aggregateVerifierType: .singleIdVerifier, aggregateVerifierName: expectedVerifier, subVerifierDetails: subVerifier, factory: factory)
        var mockTorusUtils = CustomAuth.torusUtils as! MockAbstractTorusUtils

        // Set Mock data
        mockTorusUtils.retrieveShares_output["privateKey"] = expectedPrivateKey
        mockTorusUtils.retrieveShares_output["publicAddress"] = expectedPublicAddress

        CustomAuth.getAggregateTorusKey(verifier: expectedVerifier, verifierId: expectedVerfierId, idToken: fakeData.generateVerifier(), subVerifierDetails: subVerifier[0])
            .done { data in
                let mockTorusUtils = CustomAuth.torusUtils as! MockAbstractTorusUtils
                XCTAssertEqual(mockTorusUtils.retrieveShares_input["endpoints"] as? [String], CustomAuth.endpoints)
                XCTAssertEqual(mockTorusUtils.retrieveShares_input["verifierIdentifier"] as? String, expectedVerifier)
                XCTAssertEqual(mockTorusUtils.retrieveShares_input["verifierId"] as? String, expectedVerfierId)
                XCTAssertEqual(data["privateKey"] as? String, expectedPrivateKey)
                XCTAssertEqual(data["publicAddress"] as? String, expectedPublicAddress)
            }.catch { err in
                XCTFail(err.localizedDescription)
            }.finally {
                expectation.fulfill()
            }
        wait(for: [expectation], timeout: 5)
    }

    static var allTests = [
        ("testGetTorusKey", testGetTorusKey),
//        ("testGetAggregateTorusKey", testGetAggregateTorusKey),
    ]
}

class fakeData {
    static func generateVerifier() -> String {
        return String.randomString(length: 10)
    }

    static func generatePrivateKey() -> String {
        let privateKey = Data.randomOfLength(32)
        return (privateKey?.toHexString())!
    }

    static func generatePublicKey() -> String {
        let privateKey = Data.randomOfLength(32)!
        let publicKey = SECP256K1.privateToPublic(privateKey: privateKey)?.subdata(in: 1 ..< 65)
        return publicKey!.toHexString()
    }

    static func generateRandomEmail(of length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var s = ""
        for _ in 0 ..< length {
            s.append(letters.randomElement()!)
        }
        return s + "@gmail.com"
    }
}
