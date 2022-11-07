@testable import CustomAuth
import JWTDecode
import TorusUtils
import UIKit
import XCTest

final class MockSDKTest: XCTestCase {
    func test_jwtDecodeTest() {
        let idToken = "eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL3RvcnVzLmF1LmF1dGgwLmNvbS8iLCJhdWQiOiJLRzd6azg5WDNRZ3R0U3lYOU5KNGZHRXlGTmhPY0pUdyIsIm5hbWUiOiJkaHJ1dkB0b3IudXMiLCJlbWFpbCI6ImRocnV2QHRvci51cyIsInNjb3BlIjoib3BlbmlkIHByb2ZpbGUgZW1haWwiLCJpYXQiOjE2NTQ2NzcwMTQsImVhdCI6MTY1NDY3NzMxNCwiZXhwIjoxNjU0Njc3MzE0fQ.3nzDGeSiQwfTVmL4T4-e5N19eD280GjtosFzcGjhWv_sUCV2YkM3i7iFIpUq7AxoPXjai5v7GTTPRu1zHPL6bg"
        let decodedData = try! decode(jwt: idToken)
        print(decodedData)
    }

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
        _ = CustomAuth.getNodeDetailsFromContract(verifier: expectedVerifier, verfierID: expectedVerfierId).done { nodeDetails in
            CustomAuth.getTorusKey(verifier: expectedVerifier, verifierId: expectedVerfierId, idToken: fakeData.generateVerifier())
                .done { data in
                    let mockTorusUtils = CustomAuth.torusUtils as! MockAbstractTorusUtils
                    XCTAssertEqual(mockTorusUtils.retrieveShares_input["endpoints"] as? [String], nodeDetails.getTorusNodeEndpoints())
                    XCTAssertEqual(mockTorusUtils.retrieveShares_input["verifierIdentifier"] as? String, expectedVerifier)
                    XCTAssertEqual(mockTorusUtils.retrieveShares_input["verifierId"] as? String, expectedVerfierId)
                    XCTAssertEqual(data["privateKey"] as? String, expectedPrivateKey)
                    XCTAssertEqual(data["publicAddress"] as? String, expectedPublicAddress)
                }.catch { err in
                    XCTFail(err.localizedDescription)
                }.finally {
                    expectation.fulfill()
                }
        }
        .catch({ err in
            XCTFail(err.localizedDescription)
        })
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
        _ = CustomAuth.getNodeDetailsFromContract(verifier: expectedVerifier, verfierID: expectedVerfierId).done { nodeDetails in
            CustomAuth.getAggregateTorusKey(verifier: expectedVerifier, verifierId: expectedVerfierId, idToken: fakeData.generateVerifier(), subVerifierDetails: subVerifier[0])
                .done { data in
                    let mockTorusUtils = CustomAuth.torusUtils as! MockAbstractTorusUtils
                    XCTAssertEqual(mockTorusUtils.retrieveShares_input["endpoints"] as? [String], nodeDetails.getTorusNodeEndpoints())
                    XCTAssertEqual(mockTorusUtils.retrieveShares_input["verifierIdentifier"] as? String, expectedVerifier)
                    XCTAssertEqual(mockTorusUtils.retrieveShares_input["verifierId"] as? String, expectedVerfierId)
                    XCTAssertEqual(data["privateKey"] as? String, expectedPrivateKey)
                    XCTAssertEqual(data["publicAddress"] as? String, expectedPublicAddress)
                }.catch { err in
                    XCTFail(err.localizedDescription)
                }.finally {
                    expectation.fulfill()
                }
        }
        .catch({ err in
            XCTFail(err.localizedDescription)
        })

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
