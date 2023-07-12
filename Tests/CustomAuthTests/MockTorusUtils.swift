import CustomAuth
import FetchNodeDetails
import Foundation
import CommonSources
import BigInt
@testable import TorusUtils

// Added so the that we can assign values later.
public protocol MockAbstractTorusUtils {
    var retrieveShares_input: [String: Any] { get set }
    var retrieveShares_output: [String: String] { get set }
}

class MockTorusUtils: AbstractTorusUtils, MockAbstractTorusUtils {

    func retrieveShares(endpoints: [String], torusNodePubs: [CommonSources.TorusNodePubModel]?, verifier: String, verifierParams: VerifierParams, idToken: String, extraParams: [String : Codable]) async throws -> RetrieveSharesResponse {
        retrieveShares_input = [
            "endpoints": endpoints,
            "verifierIdentifier": verifier,
            "verifierId": verifierParams.verifier_id,
            "idToken": idToken,
            "extraParams": extraParams
        ]
        return .init(ethAddress: retrieveShares_output["publicAddress"] ?? "", privKey: retrieveShares_output["privateKey"] ?? "", sessionTokenData: [], X: "", Y: "", metadataNonce: BigInt(0), postboxPubKeyX: "", postboxPubKeyY: "", sessionAuthKey: "", nodeIndexes: [])
    }
    
    func getPublicAddress(endpoints: [String], torusNodePubs: [CommonSources.TorusNodePubModel]?, verifier: String, verifierId: String, extendedVerifierId: String?) async throws -> String {
        return ""
    }

    func getUserTypeAndAddress(endpoints: [String], torusNodePubs: [TorusNodePubModel]?, verifier: String, verifierID: String, doesKeyAssign: Bool)async throws -> GetUserAndAddress{
        return .init(typeOfUser: .v1, address: "", x: "", y: "")
    }

    func getOrSetNonce(x: String, y: String, privateKey: String?, getOnly: Bool) async throws -> GetOrSetNonceResult {
        return GetOrSetNonceResult(typeOfUser: "v1")
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
