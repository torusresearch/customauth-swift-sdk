//
//  CustomAuth class
//  CustomAuth
//
//  Created by Shubham Rathi on 24/4/2020.
//

import FetchNodeDetails
import Foundation
import OSLog
import TorusUtils
import UIKit
import CommonSources

// Global variable
var tsSdkLogType = OSLogType.default

public struct TorusKeyData {
    public let torusKey : TorusKey
    public var userInfo : [String: Any]
    
    public init(torusKey: TorusKey, userInfo: [String : Any]) {
        self.torusKey = torusKey
        self.userInfo = userInfo
    }
}

/// Provides integration of an iOS app with Torus CustomAuth.
open class CustomAuth {
    var nodeDetailManager: NodeDetailManager
    var torusUtils: AbstractTorusUtils
    var urlSession: URLSession
    var enableOneKey: Bool
    ///  You can pass your own custom url  rather than using our default infura url,
    ///  can be used to get around the Ropsten depreciation from Infura API.
    var networkUrl: String?
    public let aggregateVerifierType: verifierTypes?
    public let aggregateVerifier: String
    public let subVerifierDetails: [SubVerifierDetails]
    public var authorizeURLHandler: URLOpenerTypes?
    var observer: NSObjectProtocol? // useful for Notifications
    var network : TorusNetwork

    /// Initiate an CustomAuth instance.
    /// - Parameters:
    ///   - aggregateVerifierType: Type of the verifier. Use `singleLogin` for single providers. Only `singleLogin` and `singleIdVerifier` is supported currently.
    ///   - aggregateVerifier: Name of the verifier to be used..
    ///   - subVerifierDetails: Details of each subverifiers to be used.
    ///   - factory: Providng mocking by implementing TDSDKFactoryProtocol.
    ///   - network: Etherum network to be used.
    ///   - loglevel: Indicates the log level of this instance. All logs lower than this level will be ignored.
    public init(web3AuthClientId: String = "", aggregateVerifierType: verifierTypes, aggregateVerifier: String, subVerifierDetails: [SubVerifierDetails], network: TorusNetwork = .legacy(.MAINNET), loglevel: OSLogType = .debug, urlSession: URLSession = URLSession.shared, enableOneKey: Bool = false, networkUrl: String? = nil) {
        tsSdkLogType = loglevel
        self.networkUrl = networkUrl
        self.enableOneKey = enableOneKey
        // factory method
        self.nodeDetailManager = NodeDetailManager(network: network)
        self.urlSession = urlSession
        
        self.torusUtils = TorusUtils(loglevel: loglevel, urlSession: urlSession, enableOneKey: enableOneKey, serverTimeOffset: 1000,  network: network)

        // verifier details
        self.aggregateVerifier = aggregateVerifier
        self.aggregateVerifierType = aggregateVerifierType
        self.subVerifierDetails = subVerifierDetails
        self.network = network
    }

    /// Initiate an CustomAuth instance.
    /// - Parameters:
    ///   - aggregateVerifierType: Type of the verifier. Use `singleLogin` for single providers. Only `singleLogin` and `singleIdVerifier` is supported currently.
    ///   - aggregateVerifier: Name of the verifier to be used..
    ///   - subVerifierDetails: Details of each subverifiers to be used.
    public convenience init(web3AuthClientId: String = "", aggregateVerifierType: verifierTypes, aggregateVerifier: String, subVerifierDetails: [SubVerifierDetails], enableOneKey: Bool = false, networkUrl: String? = nil) {
//        let factory = CASDKFactory()
        self.init(web3AuthClientId: web3AuthClientId, aggregateVerifierType: aggregateVerifierType, aggregateVerifier: aggregateVerifier, subVerifierDetails: subVerifierDetails, network: .legacy(.MAINNET), loglevel: .debug, enableOneKey: enableOneKey, networkUrl: networkUrl)
    }

    public convenience init(web3AuthClientId: String = "", aggregateVerifierType: verifierTypes, aggregateVerifier: String, subVerifierDetails: [SubVerifierDetails], loglevel: OSLogType = .debug, enableOneKey: Bool = false, networkUrl: String? = nil) {
//        let factory = CASDKFactory()
        self.init(web3AuthClientId: web3AuthClientId, aggregateVerifierType: aggregateVerifierType, aggregateVerifier: aggregateVerifier, subVerifierDetails: subVerifierDetails, network: .legacy(.MAINNET), loglevel: loglevel, enableOneKey: enableOneKey, networkUrl: networkUrl)
    }

    /// Retrieve information of Torus nodes from a predefined Etherum contract.
    /// - Returns: An array of URLs to the nodes.
    open func getNodeDetailsFromContract(verifier: String, verfierID: String) async throws -> AllNodeDetailsModel {
        let nodeDetails = try await nodeDetailManager.getNodeDetails(verifier: verifier, verifierID: verfierID)
        return nodeDetails
    }

    /// Trigger login flow.
    /// - Parameters:
    ///   - controller: A `UIViewController` used for providing context for the login flow.
    ///   - browserType: Indicates the way to open the browser for login flow. Use `.external` for opening system safari, or `.asWebAuthSession` for opening an in-app ASwebAuthenticationSession.
    ///   - modalPresentationStyle: Indicates the UIModalPresentationStyle for the popup.
    /// - Returns: A promise that resolve with a Dictionary that contain at least `privateKey` and `publicAddress` field..
    open func triggerLogin(controller: UIViewController? = nil, browserType: URLOpenerTypes = .asWebAuthSession, modalPresentationStyle: UIModalPresentationStyle = .fullScreen) async throws -> TorusKeyData {
        os_log("triggerLogin called with %@ %@", log: getTorusLogger(log: CASDKLogger.core, type: .info), type: .info, browserType.rawValue, modalPresentationStyle.rawValue)
        // Set browser
        authorizeURLHandler = browserType

        switch aggregateVerifierType {
        case .singleLogin:
            return try await handleSingleLogins(controller: controller, modalPresentationStyle: modalPresentationStyle)
        case .andAggregateVerifier:
            return try await handleAndAggregateVerifier(controller: controller)
        case .orAggregateVerifier:
            return try await handleOrAggregateVerifier(controller: controller)
        case .singleIdVerifier:
            return try await handleSingleIdVerifier(controller: controller, modalPresentationStyle: modalPresentationStyle)
        case .none:
            throw CASDKError.methodUnavailable
        }
    }

    open func handleSingleLogins(controller: UIViewController?, modalPresentationStyle: UIModalPresentationStyle = .fullScreen) async throws -> TorusKeyData {
        if let subVerifier = subVerifierDetails.first {
            let loginURL = subVerifier.getLoginURL()
            await openURL(url: loginURL, view: controller, modalPresentationStyle: modalPresentationStyle)
            
            let url = try await withUnsafeThrowingContinuation { (continuation: UnsafeContinuation<URL, Error>) in
                observeCallbackWithError { url, err in
                    guard
                        err == nil,
                        let url = url
                    else {
                        continuation.resume(throwing: err!)
                        return
                    }

                    continuation.resume(returning: url)
                    return
                    }
                }
            let responseParameters = self.parseURL(url: url)
            os_log("ResponseParams after redirect: %@", log: getTorusLogger(log: CASDKLogger.core, type: .info), type: .info, responseParameters)
                    do {
                        let newData = try await subVerifier.getUserInfo(responseParameters: responseParameters)
                        os_log("getUserInfo newData: %@", log: getTorusLogger(log: CASDKLogger.core, type: .info), type: .info, newData)
                        var data = newData
                        let verifierId = data["verifierId"] as! String
                        let idToken = data["tokenForKeys"] as! String
                        data.removeValue(forKey: "tokenForKeys")
                        data.removeValue(forKey: "verifierId")
                        
          
                        let torusKey = try await getTorusKey(verifier: self.aggregateVerifier, verifierId: verifierId, idToken: idToken, userData: data)
                        var mergedUserInfo = newData.merging(responseParameters) { (_, new) in new }
                        mergedUserInfo["verifier"] = self.aggregateVerifier
                        let result =  TorusKeyData(torusKey: torusKey, userInfo: mergedUserInfo)
                        return result
                    } catch {
                        os_log("handleSingleLogin: err: %s", log: getTorusLogger(log: CASDKLogger.core, type: .error), type: .error, error.localizedDescription)
                        throw error
                    }

            // Open in external safari
                }
        throw CASDKError.unknownError
        }

    open func handleSingleIdVerifier(controller: UIViewController?, modalPresentationStyle: UIModalPresentationStyle = .fullScreen) async throws -> TorusKeyData {
        if let subVerifier = subVerifierDetails.first {
            let loginURL = subVerifier.getLoginURL()
            await MainActor.run(body: {
            openURL(url: loginURL, view: controller, modalPresentationStyle: modalPresentationStyle)
            })

            let url = try await withUnsafeThrowingContinuation { (continuation: UnsafeContinuation<URL, Error>) in
                observeCallbackWithError { url, err in
                    guard
                        err == nil,
                        let url = url
                    else {
                        continuation.resume(throwing: err!)
                        return
                    }

                    continuation.resume(returning: url)
                    return
                    }
                }
                let responseParameters = self.parseURL(url: url)
                os_log("ResponseParams after redirect: %@", log: getTorusLogger(log: CASDKLogger.core, type: .info), type: .info, responseParameters)
            do {
               let newData = try await subVerifier.getUserInfo(responseParameters: responseParameters)
                    var data = newData
                    let verifierId = data["verifierId"] as! String
                    let idToken = data["tokenForKeys"] as! String
                    data.removeValue(forKey: "tokenForKeys")
                    data.removeValue(forKey: "verifierId")
                    let aggTorusKey = try await getAggregateTorusKey(verifier: self.aggregateVerifier, verifierId: verifierId, idToken: idToken, subVerifierDetails: subVerifier, userData: newData)
                var mergedUserInfo = newData.merging(responseParameters) { (_, new) in new }
                mergedUserInfo["verifier"] = self.aggregateVerifier
                let result =  TorusKeyData(torusKey: aggTorusKey, userInfo: mergedUserInfo)
                return result
                } catch {
                    os_log("handleSingleIdVerifier err: %s", log: getTorusLogger(log: CASDKLogger.core, type: .error), type: .error, error.localizedDescription)
                    throw error
                }

            }
        throw CASDKError.unknownError

        }

    func handleAndAggregateVerifier(controller: UIViewController?) async throws -> TorusKeyData {
        // TODO: implement verifier
        throw CASDKError.methodUnavailable
    }

    func handleOrAggregateVerifier(controller: UIViewController?) async throws -> TorusKeyData {
        // TODO: implement verifier
        throw CASDKError.methodUnavailable
    }

    /// Retrieve the Torus key from the nodes given an already known token. Useful if a custom login flow is required.
    /// - Parameters:
    ///   - verifier: A verifier is a unique identifier for your OAuth registration on the torus network. The public/private keys generated for a user are scoped to a verifier.
    ///   - verifierId: The unique identifier to publicly represent a user on a verifier. e.g: email, sub etc. other fields can be classified as verifierId,
    ///   - idToken: Access token received from the OAuth provider.
    ///   - userData: Custom data that will be returned with `privateKey` and `publicAddress`.
    /// - Returns: A promise that resolve with a Dictionary that contain at least `privateKey` and `publicAddress` field..
    open func getTorusKey(verifier: String, verifierId: String, idToken: String, userData: [String: Any] = [:]) async throws -> TorusKey {
        let extraParams = ["verifier_id": verifierId] as [String: Codable]
        let buffer: Data = try! NSKeyedArchiver.archivedData(withRootObject: extraParams, requiringSecureCoding: false)
        let verifierParams = VerifierParams(verifier_id: verifierId)
        do {
            let nodeDetails = try await nodeDetailManager.getNodeDetails(verifier: verifier, verifierID: verifierId)
            // retrieveShares internall checks if network is legacy and calls getPublicAddress if required.
            let responseFromRetrieveShares : TorusKey = try await torusUtils.retrieveShares(endpoints: nodeDetails.torusNodeEndpoints, torusNodePubs: nodeDetails.torusNodePub, indexes: nodeDetails.torusIndexes, verifier: verifier, verifierParams: verifierParams, idToken: idToken, extraParams: extraParams)
           
            return responseFromRetrieveShares
        } catch {
            os_log("handleSingleLogin: err: %s", log: getTorusLogger(log: CASDKLogger.core, type: .error), type: .error, error.localizedDescription)
            throw error
        }
    }

    /// Retrieve the Torus key from the nodes given an already known token. Useful if a custom aggregate login flow is required.
    /// - Parameters:
    ///   - verifier: A verifier is a unique identifier for your OAuth registration on the torus network. The public/private keys generated for a user are scoped to a verifier.
    ///   - verifierId: The unique identifier to publicly represent a user on a verifier. e.g: email, sub etc. other fields can be classified as verifierId,
    ///   - subVerifierDetails: An array of verifiers to be used for the aggregate login flow, with their respective token and verifier name.
    /// - Returns: A promise that resolve with a Dictionary that contain at least `privateKey` and `publicAddress` field..
    open func getAggregateTorusKey(verifier: String, verifierId: String, idToken: String, subVerifierDetails: SubVerifierDetails, userData: [String: Any] = [:]) async throws -> TorusKey {
        let extraParams = ["verifieridentifier": verifier, "verifier_id": verifierId, "sub_verifier_ids": [subVerifierDetails.verifier], "verify_params": [["verifier_id": verifierId, "idtoken": idToken]]] as [String: Codable]
        let buffer: Data = try! NSKeyedArchiver.archivedData(withRootObject: extraParams, requiringSecureCoding: false)
        let hashedOnce = idToken.sha3(.keccak256)
        
        let verifierParams = VerifierParams(verifier_id: verifierId)
        
        do {
            let nodeDetails = try await getNodeDetailsFromContract(verifier: verifier, verfierID: verifierId)
            
            // retrieveShares internall checks if network is legacy and calls getPublicAddress if required.
            let responseFromRetrieveShares :TorusKey =  try await self.torusUtils.retrieveShares(endpoints: nodeDetails.torusNodeEndpoints, torusNodePubs: nodeDetails.torusNodePub, indexes: nodeDetails.torusIndexes, verifier: verifier, verifierParams: verifierParams, idToken: hashedOnce, extraParams: extraParams)
        
            return responseFromRetrieveShares
        } catch {
            os_log("handleSingleIdVerifier err: %@", log: getTorusLogger(log: CASDKLogger.core, type: .error), type: .error, error.localizedDescription)
            throw error
        }
    }
}
