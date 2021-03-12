//
//  TorusSwiftDirectSDK class
//  TorusSwiftDirectSDK
//
//  Created by Shubham Rathi on 24/4/2020.
//

import Foundation
import UIKit
import TorusUtils
import PromiseKit
import FetchNodeDetails
import BestLogger

@available(iOS 11.0, *)
open class TorusSwiftDirectSDK{
    
    var torusUtils : TorusUtils!
    var endpoints = Array<String>()
    var torusNodePubKeys = Array<TorusNodePub>()
    let aggregateVerifierType: verifierTypes?
    let aggregateVerifierName: String
    let fnd: FetchNodeDetails
    let subVerifierDetails: [SubVerifierDetails]
    let logger: BestLogger
    var authorizeURLHandler: URLOpenerTypes?
    var observer: NSObjectProtocol? // useful for Notifications
        
    public init(aggregateVerifierType: verifierTypes, aggregateVerifierName: String, subVerifierDetails: [SubVerifierDetails], network: EthereumNetwork = .ROPSTEN, loglevel: BestLogger.Level = .none){
        // loggers
        self.torusUtils = TorusUtils(label: "TorusUtils", loglevel: loglevel)
        self.logger = BestLogger(label: "TorusLogger", level: loglevel)
        
        // FetchNodedetails - Initialised with ropsten proxyaddress
        // for mainnet - 0x638646503746d5456209e33a2ff5e3226d698bea
        self.fnd = FetchNodeDetails(proxyAddress: (network == .MAINNET ? "0x638646503746d5456209e33a2ff5e3226d698bea" : "0x4023d2a0D330bF11426B12C6144Cfb96B7fa6183"), network: network, logLevel: loglevel)

        // verifier details
        self.aggregateVerifierName = aggregateVerifierName
        self.aggregateVerifierType = aggregateVerifierType
        self.subVerifierDetails = subVerifierDetails
    }
    
    public func getEndpoints() -> Promise<Array<String>>{
        let (tempPromise, seal) = Promise<Array<String>>.pending()
        if(self.endpoints.isEmpty ||  self.torusNodePubKeys.isEmpty){
            do{
                let _ = try self.fnd.getNodeDetailsPromise().done{ NodeDetails  in
                    
                    // Reinit for the 1st login or if data is missing
                    self.torusNodePubKeys = NodeDetails.getTorusNodePub()
                    self.endpoints = NodeDetails.getTorusNodeEndpoints()
                    self.torusUtils = TorusUtils(label: "TorusUtils", loglevel: self.logger.logLevel, nodePubKeys: self.torusNodePubKeys)
                    seal.fulfill(self.endpoints)
                }
            }catch{
                seal.reject("failed")
            }
        }else{
            seal.fulfill(self.endpoints)
        }
        
        return tempPromise
    }
    
    public func triggerLogin(controller: UIViewController? = nil, browserType: URLOpenerTypes = .sfsafari) -> Promise<[String:Any]>{
        
        // Set browser
        self.authorizeURLHandler = browserType
        
        switch self.aggregateVerifierType{
        case .singleLogin:
            return handleSingleLogins(controller: controller)
        case .andAggregateVerifier:
            return handleAndAggregateVerifier(controller: controller)
        case .orAggregateVerifier:
            return handleOrAggregateVerifier(controller: controller)
        case .singleIdVerifier:
            return handleSingleIdVerifier(controller: controller)
        case .none:
            return Promise(error: TSDSError.methodUnavailable)
        }
    }
    
    public func handleSingleLogins(controller: UIViewController?) -> Promise<[String:Any]>{
        let (tempPromise, seal) = Promise<[String:Any]>.pending()
        if let subVerifier = self.subVerifierDetails.first{
            let loginURL = subVerifier.getLoginURL()
            observeCallback{ url in
                self.logger.info(url)
                var responseParameters = [String: String]()
                if let query = url.query {
                    responseParameters += query.parametersFromQueryString
                }
                if let fragment = url.fragment, !fragment.isEmpty {
                    responseParameters += fragment.parametersFromQueryString
                }
                self.logger.info("ResponseParams after redirect: ", responseParameters)
                subVerifier.getUserInfo(responseParameters: responseParameters).then{ newData -> Promise<[String: Any]> in
                    self.logger.info(newData)
                    var data = newData
                    let verifierId = data["verifierId"] as! String
                    let idToken = data["tokenForKeys"] as! String
                    data.removeValue(forKey: "tokenForKeys")
                    data.removeValue(forKey: "verifierId")
                        
                    return self.getTorusKey(verifier: self.aggregateVerifierName, verifierId: verifierId, idToken: idToken, userData: data)
                }.done{data in
                    seal.fulfill(data)
                }.catch{err in
                    self.logger.error("handleSingleLogin: err:", err)
                    seal.reject(err)
                }
            }
            openURL(url: loginURL, view: controller) // Open in external safari
        }
        return tempPromise
    }
    
    public func handleSingleIdVerifier(controller: UIViewController?) -> Promise<[String:Any]>{
        let (tempPromise, seal) = Promise<[String:Any]>.pending()
        if let subVerifier = self.subVerifierDetails.first{
            let loginURL = subVerifier.getLoginURL()
            observeCallback{ url in
                var responseParameters = [String: String]()
                if let query = url.query {
                    responseParameters += query.parametersFromQueryString
                }
                if let fragment = url.fragment, !fragment.isEmpty {
                    responseParameters += fragment.parametersFromQueryString
                }
                
                subVerifier.getUserInfo(responseParameters: responseParameters).then{ newData -> Promise<[String:Any]> in
                    var data = newData
                    let verifierId = data["verifierId"] as! String
                    let idToken = data["tokenForKeys"] as! String
                    data.removeValue(forKey: "tokenForKeys")
                    data.removeValue(forKey: "verifierId")
                    
                    return self.getAggregateTorusKey(verifier: self.aggregateVerifierName, verifierId: verifierId, idToken: idToken, subVerifierDetails: subVerifier, userData: newData)

                }.done{data in
                    seal.fulfill(data)
                }.catch{err in
                    self.logger.error("handleSingleIdVerifier err:", err)
                    seal.reject(err)
                }
            }
            openURL(url: loginURL, view: controller)
        }
        return tempPromise
    }
    
    func handleAndAggregateVerifier(controller: UIViewController?) -> Promise<[String:Any]>{
        // TODO: implement verifier
        return Promise(error: TSDSError.methodUnavailable)
    }
    
    func handleOrAggregateVerifier(controller: UIViewController?) -> Promise<[String:Any]>{
        // TODO: implement verifier
        return Promise(error: TSDSError.methodUnavailable)
    }
    
    public func getTorusKey(verifier: String, verifierId: String, idToken:String, userData: [String: Any] = [:] ) -> Promise<[String: Any]>{
        let extraParams = ["verifieridentifier": self.aggregateVerifierName, "verifier_id":verifierId] as [String : Any]
        let buffer: Data = try! NSKeyedArchiver.archivedData(withRootObject: extraParams, requiringSecureCoding: false)
        
        let (tempPromise, seal) = Promise<[String: Any]>.pending()
        
        self.getEndpoints().then{ endpoints in
            return self.torusUtils.retrieveShares(endpoints: endpoints, verifierIdentifier: self.aggregateVerifierName, verifierId: verifierId, idToken: idToken, extraParams: buffer)
        }.done{ responseFromRetrieveShares in
            var data = userData
            data["privateKey"] = responseFromRetrieveShares["privateKey"]
            data["publicAddress"] = responseFromRetrieveShares["publicAddress"]
            seal.fulfill(data)
        }.catch{err in
            self.logger.error("handleSingleLogin: err:", err)
            seal.reject(err)
        }
        
        return tempPromise
    }
    
    public func getAggregateTorusKey(verifier: String, verifierId: String, idToken:String, subVerifierDetails: SubVerifierDetails, userData: [String: Any] = [:]) -> Promise<[String: Any]>{
        
        let extraParams = ["verifieridentifier": verifier, "verifier_id":verifierId, "sub_verifier_ids":[subVerifierDetails.subVerifierId], "verify_params": [["verifier_id": verifierId, "idtoken": idToken]]] as [String : Any]
        let buffer: Data = try! NSKeyedArchiver.archivedData(withRootObject: extraParams, requiringSecureCoding: false)
        let hashedOnce = idToken.sha3(.keccak256)
        
        let (tempPromise, seal) = Promise<[String: Any]>.pending()

        self.getEndpoints().then{ endpoints in
            return self.torusUtils.retrieveShares(endpoints: endpoints, verifierIdentifier: verifier, verifierId: verifierId, idToken: hashedOnce, extraParams: buffer)
        }.done{responseFromRetrieveShares in
            var data = userData
            data["privateKey"] = responseFromRetrieveShares["privateKey"]
            data["publicAddress"] = responseFromRetrieveShares["publicAddress"]
            seal.fulfill(data)
        }.catch{err in
            self.logger.error("handleSingleIdVerifier err:", err)
            seal.reject(err)
        }
        
        return tempPromise
    }
}
