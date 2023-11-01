@testable import CustomAuth
import JWTDecode
import secp256k1
import TorusUtils
import UIKit
import XCTest

final class MockSDKTest: XCTestCase {
    func test_jwtDecodeTest() {
        let idToken = "eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL3RvcnVzLmF1LmF1dGgwLmNvbS8iLCJhdWQiOiJLRzd6azg5WDNRZ3R0U3lYOU5KNGZHRXlGTmhPY0pUdyIsIm5hbWUiOiJkaHJ1dkB0b3IudXMiLCJlbWFpbCI6ImRocnV2QHRvci51cyIsInNjb3BlIjoib3BlbmlkIHByb2ZpbGUgZW1haWwiLCJpYXQiOjE2NTQ2NzcwMTQsImVhdCI6MTY1NDY3NzMxNCwiZXhwIjoxNjU0Njc3MzE0fQ.3nzDGeSiQwfTVmL4T4-e5N19eD280GjtosFzcGjhWv_sUCV2YkM3i7iFIpUq7AxoPXjai5v7GTTPRu1zHPL6bg"
        let decodedData = try! decode(jwt: idToken)
        print(decodedData)
    }

    func testGetTorusKey() async throws {
        let expectedPrivateKey = try fakeData.generatePrivateKey()
        let expectedPublicAddress = try fakeData.generatePublicKey()
        let expectedVerifier = fakeData.generateVerifier()
        let expectedVerfierId = fakeData.generateRandomEmail(of: 6)

        let CustomAuth = CustomAuth(aggregateVerifierType: .singleLogin, aggregateVerifier: expectedVerifier, subVerifierDetails: [])
        let mockTorusUtils = MockTorusUtils()
        CustomAuth.torusUtils = mockTorusUtils
        // Set Mock data
        mockTorusUtils.retrieveShares_output["privateKey"] = expectedPrivateKey
        mockTorusUtils.retrieveShares_output["publicAddress"] = expectedPublicAddress
        let nodeDetails = try await CustomAuth.getNodeDetailsFromContract(verifier: expectedVerifier, verfierID: expectedVerfierId)
        let data = try await CustomAuth.getTorusKey(verifier: expectedVerifier, verifierId: expectedVerfierId, idToken: fakeData.generateVerifier())
        // let mockTorusUtils = CustomAuth.torusUtils as! MockAbstractTorusUtils
        let FinalKeyData = data["finalKeyData"] as! [String: Any]
        print(FinalKeyData)
        XCTAssertEqual(mockTorusUtils.retrieveShares_input["endpoints"] as? [String], nodeDetails.getTorusNodeEndpoints())
        XCTAssertEqual(mockTorusUtils.retrieveShares_input["verifierIdentifier"] as? String, expectedVerifier)
        XCTAssertEqual(mockTorusUtils.retrieveShares_input["verifierId"] as? String, expectedVerfierId)
        XCTAssertEqual(FinalKeyData["privKey"] as! String, expectedPrivateKey)
        XCTAssertEqual(FinalKeyData["evmAddress"] as! String, expectedPublicAddress)
    }

    func testGetAggregateTorusKey() async throws {
        let expectedPrivateKey = try fakeData.generatePrivateKey()
        let expectedPublicAddress = try fakeData.generatePublicKey()
        let expectedVerifier = fakeData.generateVerifier()
        let expectedVerfierId = fakeData.generateRandomEmail(of: 6)

        let subVerifier = [SubVerifierDetails(loginProvider: .jwt, clientId: fakeData.generateVerifier(), verifier: expectedVerifier, redirectURL: fakeData.generateVerifier())]

        let CustomAuth = CustomAuth(aggregateVerifierType: .singleIdVerifier, aggregateVerifier: expectedVerifier, subVerifierDetails: subVerifier)
        let mockTorusUtils = MockTorusUtils()
        CustomAuth.torusUtils = mockTorusUtils

        // Set Mock data
        mockTorusUtils.retrieveShares_output["privateKey"] = expectedPrivateKey
        mockTorusUtils.retrieveShares_output["publicAddress"] = expectedPublicAddress
        let nodeDetails = try await CustomAuth.getNodeDetailsFromContract(verifier: expectedVerifier, verfierID: expectedVerfierId)
        let data = try await CustomAuth.getAggregateTorusKey(verifier: expectedVerifier, verifierId: expectedVerfierId, idToken: fakeData.generateVerifier(), subVerifierDetails: subVerifier[0])
        print("Data", data)
        let FinalKeyData = data["finalKeyData"] as! [String: Any]
        // let mockTorusUtils = CustomAuth.torusUtils as! MockAbstractTorusUtils
        XCTAssertEqual(mockTorusUtils.retrieveShares_input["endpoints"] as? [String], nodeDetails.getTorusNodeEndpoints())
        XCTAssertEqual(mockTorusUtils.retrieveShares_input["verifierIdentifier"] as? String, expectedVerifier)
        XCTAssertEqual(mockTorusUtils.retrieveShares_input["verifierId"] as? String, expectedVerfierId)
        XCTAssertEqual(FinalKeyData["privKey"] as! String, expectedPrivateKey)
        XCTAssertEqual(FinalKeyData["evmAddress"] as! String, expectedPublicAddress)
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

    static func generatePrivateKey() throws -> String {
        let privateKey = try secp256k1.KeyAgreement.PrivateKey(format: .uncompressed)
        return (privateKey.rawRepresentation.toHexString())
    }

    static func generatePublicKey() throws -> String {
        let privateKey = try secp256k1.KeyAgreement.PrivateKey(format: .uncompressed)
        let publicKey = privateKey.publicKey
        return publicKey.dataRepresentation[1 ... 64].hexString
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
