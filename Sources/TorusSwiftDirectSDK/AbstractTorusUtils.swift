import Foundation
import BestLogger
import PromiseKit
import FetchNodeDetails

public protocol AbstractTorusUtils {
    func initialize(label: String, loglevel: BestLogger.Level) -> Void;
    func initialize(label: String, loglevel: BestLogger.Level, nodePubKeys: Array<TorusNodePub>) -> Void;
    func retrieveShares(endpoints: Array<String>, verifierIdentifier: String, verifierId:String, idToken: String, extraParams: Data) -> Promise<[String:String]>;
}
