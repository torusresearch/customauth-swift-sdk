//import Foundation
//import BestLogger
//import PromiseKit
//import FetchNodeDetails
//import TorusUtils
//
//public class MainTorusUtils: AbstractTorusUtils {
//    public func setTorusNodePubKeys(nodePubKeys: Array<TorusNodePub>) {
//        <#code#>
//    }
//    
//    public func getPublicAddress(endpoints: Array<String>, torusNodePubs: Array<TorusNodePub>, verifier: String, verifierId: String, isExtended: Bool) -> Promise<[String : String]> {
//        <#code#>
//    }
//    
//    var torusUtils: TorusUtils
//    
//    public init() {
//        self.torusUtils = TorusUtils()
//    }
//        
//    public func initialize(label: String, loglevel: BestLogger.Level) {
//        self.torusUtils = TorusUtils(label: label, loglevel: loglevel, nodePubKeys: [])
//    }
//    
//    public func initialize(label: String, loglevel: BestLogger.Level, nodePubKeys: Array<TorusNodePub>) {
//        self.torusUtils = TorusUtils(label: label, loglevel: loglevel, nodePubKeys: nodePubKeys)
//    }
//    
//    public func retrieveShares(endpoints: Array<String>, verifierIdentifier: String, verifierId: String, idToken: String, extraParams: Data) -> Promise<[String : String]> {
//        return self.torusUtils.retrieveShares(endpoints: endpoints, verifierIdentifier: verifierIdentifier, verifierId: verifierId, idToken: idToken, extraParams: extraParams)
//    }
//}
