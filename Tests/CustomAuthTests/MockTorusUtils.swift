import Foundation
import PromiseKit
import TorusUtils
import FetchNodeDetails
import CustomAuth

// Added so the that we can assign values later.
public protocol MockAbstractTorusUtils{
    var retrieveShares_input: [String: Any] {get set}
    var retrieveShares_output: [String: String] {get set}
}

class MockTorusUtils: AbstractTorusUtils, MockAbstractTorusUtils {
    
    var retrieveShares_input: [String:Any] = [:];
    var retrieveShares_output: [String: String] = [
        "privateKey": "<private key>",
        "publicAddress": "<public address>"
    ]
    
    var label: String?
    var nodePubKeys: Array<TorusNodePub>?

    init(){
        
    }
    
    func setTorusNodePubKeys(nodePubKeys: Array<TorusNodePub>) {
        self.nodePubKeys = nodePubKeys
    }
    
    func getPublicAddress(endpoints: Array<String>, torusNodePubs: Array<TorusNodePub>, verifier: String, verifierId: String, isExtended: Bool) -> Promise<[String : String]> {
        return Promise.value(["publicAddress" : retrieveShares_output["publicAddress"] ?? ""])
    }

    func retrieveShares(endpoints: Array<String>, verifierIdentifier: String, verifierId: String, idToken: String, extraParams: Data) -> Promise<[String : String]> {
        self.retrieveShares_input = [
            "endpoints": endpoints,
            "verifierIdentifier": verifierIdentifier,
            "verifierId": verifierId,
            "idToken": idToken,
            "extraParams": extraParams
        ]
        return Promise { seal in
            seal.fulfill(retrieveShares_output)
        }
    }
}
