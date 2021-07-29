import Foundation
import BestLogger
import PromiseKit
import FetchNodeDetails
import TorusUtils

public class MainTorusUtils: AbstractTorusUtils {
    var torusUtils: TorusUtils
    
    public init() {
        self.torusUtils = TorusUtils()
    }
        
    public func initialize(label: String, loglevel: BestLogger.Level) {
        self.torusUtils = TorusUtils(label: label, loglevel: loglevel)
    }
    
    public func initialize(label: String, loglevel: BestLogger.Level, nodePubKeys: Array<TorusNodePub>) {
        self.torusUtils = TorusUtils(label: label, loglevel: loglevel, nodePubKeys: nodePubKeys)
    }
    
    public func retrieveShares(endpoints: Array<String>, verifierIdentifier: String, verifierId: String, idToken: String, extraParams: Data) -> Promise<[String : String]> {
        return self.torusUtils.retrieveShares(endpoints: endpoints, verifierIdentifier: verifierIdentifier, verifierId: verifierId, idToken: idToken, extraParams: extraParams)
    }
}
