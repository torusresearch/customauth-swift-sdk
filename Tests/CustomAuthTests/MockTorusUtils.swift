import CustomAuth
import FetchNodeDetails
import Foundation
import PromiseKit
import TorusUtils
@testable import TorusUtils

// Added so the that we can assign values later.
public protocol MockAbstractTorusUtils {
    var retrieveShares_input: [String: Any] { get set }
    var retrieveShares_output: [String: String] { get set }
}

class MockTorusUtils: AbstractTorusUtils, MockAbstractTorusUtils {
    
    func getPublicAddress(endpoints: Array<String>, torusNodePubs: Array<TorusNodePubModel>, verifier: String, verifierId: String, isExtended: Bool) -> Promise<GetPublicAddressModel> {
        return Promise.value(.init(address: ""))
    }
    
    func getUserTypeAndAddress(endpoints: [String], torusNodePub: [TorusNodePubModel], verifier: String, verifierID: String, doesKeyAssign: Bool) -> Promise<GetUserAndAddressModel> {
        return Promise.value(.init(typeOfUser: .v1, address: "", x: "", y: ""))
    }
    
    func getOrSetNonce(x: String, y: String, privateKey: String?, getOnly: Bool) -> Promise<GetOrSetNonceResultModel> {
        return Promise.value(GetOrSetNonceResultModel.init(typeOfUser: "v1"))
    }
    
    var retrieveShares_input: [String: Any] = [:]
    var retrieveShares_output: [String: String] = [
        "privateKey": "<private key>",
        "publicAddress": "<public address>",
    ]

    var label: String?
    var nodePubKeys: Array<TorusNodePubModel>?

    init() {
    }

    func setTorusNodePubKeys(nodePubKeys: Array<TorusNodePubModel>) {
        self.nodePubKeys = nodePubKeys
    }

    func getPublicAddress(endpoints: Array<String>, torusNodePubs: Array<TorusNodePubModel>, verifier: String, verifierId: String, isExtended: Bool) -> Promise<[String: String]> {
        return Promise.value(["publicAddress": retrieveShares_output["publicAddress"] ?? ""])
    }

    func retrieveShares(torusNodePubs: Array<TorusNodePubModel>,endpoints: Array<String>, verifierIdentifier: String, verifierId: String, idToken: String, extraParams: Data) -> Promise<[String: String]> {
        retrieveShares_input = [
            "endpoints": endpoints,
            "verifierIdentifier": verifierIdentifier,
            "verifierId": verifierId,
            "idToken": idToken,
            "extraParams": extraParams,
        ]
        return Promise { seal in
            seal.fulfill(retrieveShares_output)
        }
    }
}
