import CustomAuth
import FetchNodeDetails
import Foundation
@testable import TorusUtils

// Added so the that we can assign values later.
public protocol MockAbstractTorusUtils {
    var retrieveShares_input: [String: Any] { get set }
    var retrieveShares_output: [String: String] { get set }
}

class MockTorusUtils: AbstractTorusUtils, MockAbstractTorusUtils {
    func getPublicAddress(endpoints: [String], torusNodePubs: [TorusNodePubModel], verifier: String, verifierId: String, isExtended: Bool) async throws -> GetPublicAddressModel {
        return .init(address: "")
    }

    func getUserTypeAndAddress(endpoints: [String], torusNodePub: [TorusNodePubModel], verifier: String, verifierID: String, doesKeyAssign: Bool)async throws -> GetUserAndAddressModel {
        return .init(typeOfUser: .v1, address: "", x: "", y: "")
    }

    func getOrSetNonce(x: String, y: String, privateKey: String?, getOnly: Bool) async throws -> GetOrSetNonceResultModel {
        return GetOrSetNonceResultModel(typeOfUser: "v1")
    }

    var retrieveShares_input: [String: Any] = [:]
    var retrieveShares_output: [String: String] = [
        "privateKey": "<private key>",
        "publicAddress": "<public address>"
    ]

    var label: String?
    var nodePubKeys: [TorusNodePubModel]?

    init() {
    }

    func setTorusNodePubKeys(nodePubKeys: [TorusNodePubModel]) {
        self.nodePubKeys = nodePubKeys
    }

    func getPublicAddress(endpoints: [String], torusNodePubs: [TorusNodePubModel], verifier: String, verifierId: String, isExtended: Bool) async throws -> [String: String] {
        return (["publicAddress": retrieveShares_output["publicAddress"] ?? ""])
    }

    func retrieveShares(torusNodePubs: [TorusNodePubModel], endpoints: [String], verifier verifierIdentifier: String, verifierId: String, idToken: String, extraParams: Data) async throws -> [String: String] {
        retrieveShares_input = [
            "endpoints": endpoints,
            "verifierIdentifier": verifierIdentifier,
            "verifierId": verifierId,
            "idToken": idToken,
            "extraParams": extraParams
        ]
        return retrieveShares_output
    }
}
