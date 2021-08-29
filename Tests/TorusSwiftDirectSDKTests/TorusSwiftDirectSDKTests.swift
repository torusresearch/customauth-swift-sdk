import XCTest
import UIKit
import Fakery
@testable import TorusSwiftDirectSDK

@available(iOS 11.0, *)
final class TorusSwiftDirectSDKTests: XCTestCase {
    let faker = Faker()

    func testGetTorusKey() {
        let expectation = XCTestExpectation(description: "getTorusKey should correctly proxy input and output to/from TorusUtils")
        
//        typealias testingSomething = AbstractTorusUtils & MockAbstractTorusUtils
        let expectedPrivateKey = faker.internet.password()
        let expectedPublicAddress = faker.internet.ipV4Address()
        let expectedVerifier = faker.internet.username()
        let expectedVerfierId = faker.internet.username()

        let subVerifier = [SubVerifierDetails(loginProvider: .jwt, clientId: faker.internet.ipV4Address(), verifierName: expectedVerifier, redirectURL: faker.internet.url())]
        let factory = MockFactory()
        
        let torusSwiftDirectSDK = TorusSwiftDirectSDK(aggregateVerifierType: .singleLogin, aggregateVerifierName: expectedVerifier, subVerifierDetails: subVerifier, factory: factory)
        var mockTorusUtils = torusSwiftDirectSDK.torusUtils as! MockAbstractTorusUtils
        
        // Set Mock data
        mockTorusUtils.retrieveShares_output["privateKey"] = expectedPrivateKey
        mockTorusUtils.retrieveShares_output["publicAddress"] = expectedPublicAddress
        
        torusSwiftDirectSDK.getTorusKey(verifier: expectedVerifier, verifierId: expectedVerfierId, idToken: faker.lorem.sentences(amount: 10))
            .done { data in
                let mockTorusUtils = torusSwiftDirectSDK.torusUtils as! MockAbstractTorusUtils
                XCTAssertEqual(mockTorusUtils.retrieveShares_input["endpoints"] as? [String], torusSwiftDirectSDK.endpoints)
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

        let expectedPrivateKey = faker.internet.password()
        let expectedPublicAddress = faker.internet.ipV4Address()
        let expectedVerifier = faker.internet.username()
        let expectedVerfierId = faker.internet.username()
        
        let subVerifier = [SubVerifierDetails(loginProvider: .jwt, clientId: faker.internet.ipV4Address(), verifierName: expectedVerifier, redirectURL: faker.internet.url())]
        let factory = MockFactory()
        
        let torusSwiftDirectSDK = TorusSwiftDirectSDK(aggregateVerifierType: .singleIdVerifier, aggregateVerifierName: expectedVerifier, subVerifierDetails: subVerifier, factory: factory)
        var mockTorusUtils = torusSwiftDirectSDK.torusUtils as! MockAbstractTorusUtils
        
        // Set Mock data
        mockTorusUtils.retrieveShares_output["privateKey"] = expectedPrivateKey
        mockTorusUtils.retrieveShares_output["publicAddress"] = expectedPublicAddress
        
        torusSwiftDirectSDK.getAggregateTorusKey(verifier: expectedVerifier, verifierId: expectedVerfierId, idToken: faker.lorem.sentences(amount: 10), subVerifierDetails: subVerifier[0])
            .done { data in
                let mockTorusUtils = torusSwiftDirectSDK.torusUtils as! MockAbstractTorusUtils
                XCTAssertEqual(mockTorusUtils.retrieveShares_input["endpoints"] as? [String], torusSwiftDirectSDK.endpoints)
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
