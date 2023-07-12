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

    func testGetTorusKey() async {
        let expectation = XCTestExpectation(description: "getTorusKey should correctly proxy input and output to/from TorusUtils")

        let expectedPrivateKey = fakeData.generatePrivateKey()
        let expectedPublicAddress = fakeData.generatePublicKey()
        let expectedVerifier = fakeData.generateVerifier()
        let expectedVerfierId = fakeData.generateRandomEmail(of: 6)

        let subVerifier = [SubVerifierDetails(loginProvider: .jwt, clientId: fakeData.generateVerifier(), verifier: expectedVerifier, redirectURL: fakeData.generateVerifier())]
        let factory = MockFactory()

//        let CustomAuth = CustomAuth(aggregateVerifierType: .singleLogin, aggregateVerifier: expectedVerifier, subVerifierDetails: subVerifiery)
        let CustomAuth = CustomAuth(aggregateVerifierType: .singleLogin, aggregateVerifier: expectedVerifier, subVerifierDetails: [])
//        var mockTorusUtils = CustomAuth.torusUtils as! MockAbstractTorusUtils
        var mockTorusUtils = MockTorusUtils()
        CustomAuth.torusUtils = mockTorusUtils
        // Set Mock data
        mockTorusUtils.retrieveShares_output["privateKey"] = expectedPrivateKey
        mockTorusUtils.retrieveShares_output["publicAddress"] = expectedPublicAddress
        do {
        let nodeDetails = try await CustomAuth.getNodeDetailsFromContract(verifier: expectedVerifier, verfierID: expectedVerfierId)
        let data = try await CustomAuth.getTorusKey(verifier: expectedVerifier, verifierId: expectedVerfierId, idToken: fakeData.generateVerifier())
                    let mockTorusUtils = CustomAuth.torusUtils as! MockAbstractTorusUtils
                    XCTAssertEqual(mockTorusUtils.retrieveShares_input["endpoints"] as? [String], nodeDetails.getTorusNodeEndpoints())
                    XCTAssertEqual(mockTorusUtils.retrieveShares_input["verifierIdentifier"] as? String, expectedVerifier)
                    XCTAssertEqual(mockTorusUtils.retrieveShares_input["verifierId"] as? String, expectedVerfierId)
                    XCTAssertEqual(data["privateKey"] as? String, expectedPrivateKey)
                    XCTAssertEqual(data["publicAddress"] as? String, expectedPublicAddress)
            expectation.fulfill()
            } catch {
                    XCTFail(error.localizedDescription)
                    expectation.fulfill()
        }
    }

    func testGetAggregateTorusKey() async {
        let expectation = XCTestExpectation(description: "getAggregateTorusKey should correctly proxy input and output to/from TorusUtils")

        let expectedPrivateKey = fakeData.generatePrivateKey()
        let expectedPublicAddress = fakeData.generatePublicKey()
        let expectedVerifier = fakeData.generateVerifier()
        let expectedVerfierId = fakeData.generateRandomEmail(of: 6)

        let subVerifier = [SubVerifierDetails(loginProvider: .jwt, clientId: fakeData.generateVerifier(), verifier: expectedVerifier, redirectURL: fakeData.generateVerifier())]
        let factory = MockFactory()

        let CustomAuth = CustomAuth(aggregateVerifierType: .singleIdVerifier, aggregateVerifier: expectedVerifier, subVerifierDetails: subVerifier)
//        var mockTorusUtils = CustomAuth.torusUtils as! MockAbstractTorusUtils
        var mockTorusUtils = MockTorusUtils()
        CustomAuth.torusUtils = mockTorusUtils

        // Set Mock data
        mockTorusUtils.retrieveShares_output["privateKey"] = expectedPrivateKey
        mockTorusUtils.retrieveShares_output["publicAddress"] = expectedPublicAddress
        do {
        let nodeDetails  = try await CustomAuth.getNodeDetailsFromContract(verifier: expectedVerifier, verfierID: expectedVerfierId)
           let data = try await CustomAuth.getAggregateTorusKey(verifier: expectedVerifier, verifierId: expectedVerfierId, idToken: fakeData.generateVerifier(), subVerifierDetails: subVerifier[0])
                    let mockTorusUtils = CustomAuth.torusUtils as! MockAbstractTorusUtils
                    XCTAssertEqual(mockTorusUtils.retrieveShares_input["endpoints"] as? [String], nodeDetails.getTorusNodeEndpoints())
                    XCTAssertEqual(mockTorusUtils.retrieveShares_input["verifierIdentifier"] as? String, expectedVerifier)
                    XCTAssertEqual(mockTorusUtils.retrieveShares_input["verifierId"] as? String, expectedVerfierId)
                    XCTAssertEqual(data["privateKey"] as? String, expectedPrivateKey)
                    XCTAssertEqual(data["publicAddress"] as? String, expectedPublicAddress)
            expectation.fulfill()
                } catch {
                    XCTFail(error.localizedDescription)
                    expectation.fulfill()
                }
    }

    static var allTests = [
        ("testGetTorusKey", testGetTorusKey)
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
