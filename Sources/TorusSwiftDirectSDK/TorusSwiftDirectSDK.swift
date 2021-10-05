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
import OSLog

// Global variable
var tsSdkLogType = OSLogType.default

@available(iOS 11.0, *)
/// Provides integration of an iOS app with Torus CustomAuth.
open class TorusSwiftDirectSDK{
    public var endpoints = Array<String>()
    public var torusNodePubKeys = Array<TorusNodePub>()

    let factory: TDSDKFactoryProtocol
    var torusUtils: AbstractTorusUtils
    let fetchNodeDetails: FetchNodeDetails

    public let aggregateVerifierType: verifierTypes?
    public let aggregateVerifierName: String
    public let subVerifierDetails: [SubVerifierDetails]
    public var authorizeURLHandler: URLOpenerTypes?
    var observer: NSObjectProtocol? // useful for Notifications
    
    /// Initiate an TorusSwiftDirectSDK instance.
    /// - Parameters:
    ///   - aggregateVerifierType: Type of the verifier. Use `singleLogin` for single providers. Only `singleLogin` and `singleIdVerifier` is supported currently.
    ///   - aggregateVerifierName: Name of the verifier to be used..
    ///   - subVerifierDetails: Details of each subverifiers to be used.
    ///   - factory: Providng mocking by implementing TDSDKFactoryProtocol.
    ///   - network: Etherum network to be used.
    ///   - loglevel: Indicates the log level of this instance. All logs lower than this level will be ignored.
    public init(aggregateVerifierType: verifierTypes, aggregateVerifierName: String, subVerifierDetails: [SubVerifierDetails], factory: TDSDKFactoryProtocol, network: EthereumNetwork = .MAINNET, loglevel: OSLogType = .debug) {
        tsSdkLogType = loglevel
        
        // factory method
        self.factory = factory
        self.torusUtils = factory.createTorusUtils(nodePubKeys: [], loglevel: loglevel)
        self.fetchNodeDetails = factory.createFetchNodeDetails(network: network)
        
        // verifier details
        self.aggregateVerifierName = aggregateVerifierName
        self.aggregateVerifierType = aggregateVerifierType
        self.subVerifierDetails = subVerifierDetails
    }
    
    /// Initiate an TorusSwiftDirectSDK instance.
    /// - Parameters:
    ///   - aggregateVerifierType: Type of the verifier. Use `singleLogin` for single providers. Only `singleLogin` and `singleIdVerifier` is supported currently.
    ///   - aggregateVerifierName: Name of the verifier to be used..
    ///   - subVerifierDetails: Details of each subverifiers to be used.
    public convenience init(aggregateVerifierType: verifierTypes, aggregateVerifierName: String, subVerifierDetails: [SubVerifierDetails]){
        let factory = TDSDKFactory()
        self.init(aggregateVerifierType: aggregateVerifierType, aggregateVerifierName: aggregateVerifierName, subVerifierDetails: subVerifierDetails, factory: factory, network: .MAINNET, loglevel: .debug)
    }
    
    /// Initiate an TorusSwiftDirectSDK instance.
    /// - Parameters:
    ///   - aggregateVerifierType: Type of the verifier. Use `singleLogin` for single providers. Only `singleLogin` and `singleIdVerifier` is supported currently.
    ///   - aggregateVerifierName: Name of the verifier to be used..
    ///   - subVerifierDetails: Details of each subverifiers to be used.
    ///   - network: Etherum network to be used.
    public convenience init(aggregateVerifierType: verifierTypes, aggregateVerifierName: String, subVerifierDetails: [SubVerifierDetails], network: EthereumNetwork){
        let factory = TDSDKFactory()
        self.init(aggregateVerifierType: aggregateVerifierType, aggregateVerifierName: aggregateVerifierName, subVerifierDetails: subVerifierDetails, factory: factory, network: network, loglevel: .debug)
    }
    
    public convenience init(aggregateVerifierType: verifierTypes, aggregateVerifierName: String, subVerifierDetails: [SubVerifierDetails], network: EthereumNetwork, loglevel: OSLogType = .debug){
        let factory = TDSDKFactory()
        self.init(aggregateVerifierType: aggregateVerifierType, aggregateVerifierName: aggregateVerifierName, subVerifierDetails: subVerifierDetails, factory: factory, network: network, loglevel: loglevel)
    }
    
    public convenience init(aggregateVerifierType: verifierTypes, aggregateVerifierName: String, subVerifierDetails: [SubVerifierDetails], loglevel: OSLogType = .debug){
        let factory = TDSDKFactory()
        self.init(aggregateVerifierType: aggregateVerifierType, aggregateVerifierName: aggregateVerifierName, subVerifierDetails: subVerifierDetails, factory: factory, network: .MAINNET, loglevel: loglevel)
    }
    
    /// Retrieve information of Torus nodes from a predefined Etherum contract.
    /// - Returns: An array of URLs to the nodes.
    open func getNodeDetailsFromContract() -> Promise<Array<String>>{
        let (tempPromise, seal) = Promise<Array<String>>.pending()
        if(self.endpoints.isEmpty || self.torusNodePubKeys.isEmpty){
            self.fetchNodeDetails.getAllNodeDetails().done{ NodeDetails  in
                // Reinit for the 1st login or if data is missing
                self.torusNodePubKeys = NodeDetails.getTorusNodePub()
                self.endpoints = NodeDetails.getTorusNodeEndpoints()
                self.torusUtils.setTorusNodePubKeys(nodePubKeys: self.torusNodePubKeys)
                // self.torusUtils = self.factory.createTorusUtils(level: self.logger.logLevel, nodePubKeys: self.torusNodePubKeys)
                seal.fulfill(self.endpoints)
            }.catch{error in
                seal.reject(error)
            }
        }else{
            seal.fulfill(self.endpoints)
        }
        
        return tempPromise
    }
    
    /// Trigger login flow.
    /// - Parameters:
    ///   - controller: A `UIViewController` used for providing context for the login flow.
    ///   - browserType: Indicates the way to open the browser for login flow. Use `.external` for opening system safari, or `.sfsafari` for opening an in-app browser.
    ///   - modalPresentationStyle: Indicates the UIModalPresentationStyle for the popup.
    /// - Returns: A promise that resolve with a Dictionary that contain at least `privateKey` and `publicAddress` field..
    open func triggerLogin(controller: UIViewController? = nil, browserType: URLOpenerTypes = .sfsafari, modalPresentationStyle: UIModalPresentationStyle = .fullScreen) -> Promise<[String:Any]>{
        os_log("triggerLogin called with %@ %@", log: getTorusLogger(log: TDSDKLogger.core, type: .info), type: .info, browserType.rawValue,  modalPresentationStyle.rawValue)
        // Set browser
        self.authorizeURLHandler = browserType
        
        switch self.aggregateVerifierType{
            case .singleLogin:
                return handleSingleLogins(controller: controller, modalPresentationStyle: modalPresentationStyle)
            case .andAggregateVerifier:
                return handleAndAggregateVerifier(controller: controller)
            case .orAggregateVerifier:
                return handleOrAggregateVerifier(controller: controller)
            case .singleIdVerifier:
                return handleSingleIdVerifier(controller: controller, modalPresentationStyle: modalPresentationStyle)
            case .none:
                return Promise(error: TSDSError.methodUnavailable)
        }
    }
    
    open func handleSingleLogins(controller: UIViewController?, modalPresentationStyle: UIModalPresentationStyle = .fullScreen) -> Promise<[String:Any]>{
        let (tempPromise, seal) = Promise<[String:Any]>.pending()
        if let subVerifier = self.subVerifierDetails.first{
            let loginURL = subVerifier.getLoginURL()
            observeCallback{ url in
                let responseParameters = self.parseURL(url: url)
                os_log("ResponseParams after redirect: %@", log: getTorusLogger(log: TDSDKLogger.core, type: .info), type: .info, responseParameters)

                subVerifier.getUserInfo(responseParameters: responseParameters).then{ newData -> Promise<[String: Any]> in
                    os_log("getUserInfo newData: %@", log: getTorusLogger(log: TDSDKLogger.core, type: .info), type: .info, newData)
                    var data = newData
                    let verifierId = data["verifierId"] as! String
                    let idToken = data["tokenForKeys"] as! String
                    data.removeValue(forKey: "tokenForKeys")
                    data.removeValue(forKey: "verifierId")
                    
                    return self.getTorusKey(verifier: self.aggregateVerifierName, verifierId: verifierId, idToken: idToken, userData: data)
                }.done{data in
                    seal.fulfill(data)
                }.catch{err in
                    os_log("handleSingleLogin: err: %s", log: getTorusLogger(log: TDSDKLogger.core, type: .error), type: .error, err.localizedDescription)
                    seal.reject(err)
                }
            }
            openURL(url: loginURL, view: controller, modalPresentationStyle: modalPresentationStyle) // Open in external safari
        }
        return tempPromise
    }
    
    open func handleSingleIdVerifier(controller: UIViewController?, modalPresentationStyle: UIModalPresentationStyle = .fullScreen) -> Promise<[String:Any]>{
        let (tempPromise, seal) = Promise<[String:Any]>.pending()
        if let subVerifier = self.subVerifierDetails.first{
            let loginURL = subVerifier.getLoginURL()
            observeCallback{ url in
                let responseParameters = self.parseURL(url: url)
                os_log("ResponseParams after redirect: %@", log: getTorusLogger(log: TDSDKLogger.core, type: .info), type: .info, responseParameters)
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
                    os_log("handleSingleIdVerifier err: %s", log: getTorusLogger(log: TDSDKLogger.core, type: .error), type: .error, err.localizedDescription)
                    seal.reject(err)
                }
            }
            openURL(url: loginURL, view: controller, modalPresentationStyle: modalPresentationStyle)
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
    
    /// Retrieve the Torus key from the nodes given an already known token. Useful if a custom login flow is required.
    /// - Parameters:
    ///   - verifier: A verifier is a unique identifier for your OAuth registration on the torus network. The public/private keys generated for a user are scoped to a verifier.
    ///   - verifierId: The unique identifier to publicly represent a user on a verifier. e.g: email, sub etc. other fields can be classified as verifierId,
    ///   - idToken: Access token received from the OAuth provider.
    ///   - userData: Custom data that will be returned with `privateKey` and `publicAddress`.
    /// - Returns: A promise that resolve with a Dictionary that contain at least `privateKey` and `publicAddress` field..
    open func getTorusKey(verifier: String, verifierId: String, idToken:String, userData: [String: Any] = [:] ) -> Promise<[String: Any]>{
        let extraParams = ["verifieridentifier": self.aggregateVerifierName, "verifier_id":verifierId] as [String : Any]
        let buffer: Data = try! NSKeyedArchiver.archivedData(withRootObject: extraParams, requiringSecureCoding: false)
        
        let (tempPromise, seal) = Promise<[String: Any]>.pending()
        
        self.getNodeDetailsFromContract().then{ endpoints -> Promise<[String:String]> in
            
            let newEndpoints = ["https://teal-15-1.torusnode.com/jrpc", "https://teal-15-3.torusnode.com/jrpc", "https://teal-15-4.torusnode.com/jrpc", "https://teal-15-5.torusnode.com/jrpc", "https://teal-15-2.torusnode.com/jrpc"]
            self.torusUtils.setTorusNodePubKeys(nodePubKeys: [TorusNodePub(_X:  "1363AAD8868CACD7F8946C590325CD463106FB3731F08811AB4302D2DEAE35C3" , _Y:  "D77EEBE5CDF466B475EC892D5B4CFFBE0C1670525DEBBD97EEE6DAE2F87A7CBE" ),
                                                                                       TorusNodePub(_X:  "7C8CC521C48690F016BEA593F67F88AD24F447DD6C31BBAB541E59E207BF029D" , _Y:  "B359F0A82608DB2E06B953B36D0C9A473A00458117CA32A5B0F4563A7D539636" ),
                                                                                       TorusNodePub(_X:  "8A86543CA17DF5687719E2549CAA024CF17FE0361E119E741EAEE668F8DD0A6F" , _Y:  "9CDB254FF915A76950D6D13D78EF054D5D0DC34E2908C00BB009A6E4DA701891" ),
                                                                                       TorusNodePub(_X:  "25A98D9AE006AED1D77E81D58BE8F67193D13D01A9888E2923841894F4B0BF9C" , _Y:  "F63D40DF480DACF68922004ED36DBAB9E2969181B047730A5CE0797FB6958249" ),
                                                                                       TorusNodePub(_X:  "D908F41F8E06324A8A7ABCF702ADB6A273CE3AE63D86A3D22723E1BBF1438C9A" , _Y:  "F977530B3EC0E525438C72D1E768380CBC5FB3B38A760EE925053B2E169428CE" )])
            return self.torusUtils.retrieveShares(endpoints: newEndpoints, verifierIdentifier: self.aggregateVerifierName, verifierId: verifierId, idToken: idToken, extraParams: buffer)
        }.done{ responseFromRetrieveShares in
            var data = userData
            data["privateKey"] = responseFromRetrieveShares["privateKey"]
            data["publicAddress"] = responseFromRetrieveShares["publicAddress"]
            seal.fulfill(data)
        }.catch{err in
            os_log("handleSingleLogin: err: %s", log: getTorusLogger(log: TDSDKLogger.core, type: .error), type: .error, err.localizedDescription)
            seal.reject(err)
        }
        
        return tempPromise
    }
    
    /// Retrieve the Torus key from the nodes given an already known token. Useful if a custom aggregate login flow is required.
    /// - Parameters:
    ///   - verifier: A verifier is a unique identifier for your OAuth registration on the torus network. The public/private keys generated for a user are scoped to a verifier.
    ///   - verifierId: The unique identifier to publicly represent a user on a verifier. e.g: email, sub etc. other fields can be classified as verifierId,
    ///   - subVerifierDetails: An array of verifiers to be used for the aggregate login flow, with their respective token and verifier name.
    /// - Returns: A promise that resolve with a Dictionary that contain at least `privateKey` and `publicAddress` field..
    open func getAggregateTorusKey(verifier: String, verifierId: String, idToken:String, subVerifierDetails: SubVerifierDetails, userData: [String: Any] = [:]) -> Promise<[String: Any]>{
        let extraParams = ["verifieridentifier": verifier, "verifier_id":verifierId, "sub_verifier_ids":[subVerifierDetails.subVerifierId], "verify_params": [["verifier_id": verifierId, "idtoken": idToken]]] as [String : Any]
        let buffer: Data = try! NSKeyedArchiver.archivedData(withRootObject: extraParams, requiringSecureCoding: false)
        let hashedOnce = idToken.sha3(.keccak256)
        
        let (tempPromise, seal) = Promise<[String: Any]>.pending()
        
        self.getNodeDetailsFromContract().then{ endpoints in
            return self.torusUtils.retrieveShares(endpoints: endpoints, verifierIdentifier: verifier, verifierId: verifierId, idToken: hashedOnce, extraParams: buffer)
        }.done{responseFromRetrieveShares in
            var data = userData
            data["privateKey"] = responseFromRetrieveShares["privateKey"]
            data["publicAddress"] = responseFromRetrieveShares["publicAddress"]
            seal.fulfill(data)
        }.catch{err in
            os_log("handleSingleIdVerifier err: %@", log: getTorusLogger(log: TDSDKLogger.core, type: .error), type: .error, err.localizedDescription)
            seal.reject(err)
        }
        
        return tempPromise
    }
    
}
