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

// Global variable
var tsSdkLogType = OSLogType.default

/// Provides integration of an iOS app with Torus CustomAuth.
open class CustomAuth {
    var factory: CASDKFactoryProtocol
    var torusUtils: AbstractTorusUtils
    var fetchNodeDetails: FetchNodeDetails

    var subVerifierDetails: [SubVerifierDetails] = []
    var observer: NSObjectProtocol? // useful for Notifications
    
    var authorizeURLHandler: URLOpenerTypes?

    public init(customAuthArgs: CustomAuthArgs) {
        if (customAuthArgs.enableLogging ?? false) {
            tsSdkLogType = .debug
        }

        // factory method
        self.factory = CASDKFactory()

        let urlSession = URLSession.shared
        torusUtils = factory.createTorusUtils(loglevel: tsSdkLogType, urlSession: urlSession, enableOneKey: customAuthArgs.enableOneKey!, network: customAuthArgs.nativeNetwork)
        fetchNodeDetails = factory.createFetchNodeDetails(network: customAuthArgs.nativeNetwork, urlSession: urlSession, networkUrl: customAuthArgs.networkUrl)
    }

    /// Retrieve information of Torus nodes from a predefined Etherum contract.
    /// - Returns: An array of URLs to the nodes.
    open func getNodeDetailsFromContract(verifier: String, verfierID: String) async throws -> AllNodeDetailsModel {
        let nodeDetails = try await fetchNodeDetails.getNodeDetails(verifier: verifier, verifierID: verfierID)
        return nodeDetails
    }

    /// Trigger login flow.
    /// - Parameters:
    ///   - controller: A `UIViewController` used for providing context for the login flow.
    ///   - browserType: Indicates the way to open the browser for login flow. Use `.external` for opening system safari, or `.asWebAuthSession` for opening an in-app ASwebAuthenticationSession.
    ///   - modalPresentationStyle: Indicates the UIModalPresentationStyle for the popup.
    /// - Returns: A promise that resolve with a Dictionary that contain at least `privateKey` and `publicAddress` field..
    
    open func triggerLogin(controller: UIViewController? = nil, subVerifierDetails: SubVerifierDetails, modalPresentationStyle: UIModalPresentationStyle = .fullScreen) async throws -> [String: Any] {
        self.subVerifierDetails = [subVerifierDetails]
        
        let browserType: URLOpenerTypes = URLOpenerTypes.asWebAuthSession
        self.authorizeURLHandler = browserType

        os_log("triggerLogin called with %@ %@", log: getTorusLogger(log: CASDKLogger.core, type: .info), type: .info, browserType.rawValue, modalPresentationStyle.rawValue)
        
        let aggregateVerifierType = verifierTypes.singleLogin;
        
        switch aggregateVerifierType {
            case .singleLogin:
                return try await handleSingleLogins(controller: controller, modalPresentationStyle: modalPresentationStyle)
            case .andAggregateVerifier:
                return try await handleAndAggregateVerifier(controller: controller)
            case .orAggregateVerifier:
                return try await handleOrAggregateVerifier(controller: controller)
            case .singleIdVerifier:
                return try await handleSingleIdVerifier(controller: controller, modalPresentationStyle: modalPresentationStyle)
            default:
                throw CASDKError.methodUnavailable
        }
    }

    open func handleSingleLogins(controller: UIViewController?, modalPresentationStyle: UIModalPresentationStyle = .fullScreen) async throws -> [String: Any] {
        if let subVerifier = subVerifierDetails.first {
            let loginURL = subVerifier.getLoginURL()
            await openURL(url: loginURL, view: controller, modalPresentationStyle: modalPresentationStyle)
            let url = await withUnsafeContinuation({ continuation in
                observeCallback { url in
                    continuation.resume(returning: url)
                }
            })

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
                        let torusKey = try await getTorusKey(verifier: self.subVerifierDetails.first!.verifier, verifierId: verifierId, idToken: idToken, userData: data)
                        return torusKey
                    } catch {
                        os_log("handleSingleLogin: err: %s", log: getTorusLogger(log: CASDKLogger.core, type: .error), type: .error, error.localizedDescription)
                        throw error
                    }

            // Open in external safari
                }
        throw CASDKError.unknownError
        }

    open func handleSingleIdVerifier(controller: UIViewController?, modalPresentationStyle: UIModalPresentationStyle = .fullScreen) async throws -> [String: Any] {
        if let subVerifier = subVerifierDetails.first {
            let loginURL = subVerifier.getLoginURL()
            await MainActor.run(body: {
            openURL(url: loginURL, view: controller, modalPresentationStyle: modalPresentationStyle)
            })

            let url = await withUnsafeContinuation({ continuation in
                observeCallback { url in
                    continuation.resume(returning: url)
                }
            })
                let responseParameters = self.parseURL(url: url)
                os_log("ResponseParams after redirect: %@", log: getTorusLogger(log: CASDKLogger.core, type: .info), type: .info, responseParameters)
            do {
               let newData = try await subVerifier.getUserInfo(responseParameters: responseParameters)
                    var data = newData
                    let verifierId = data["verifierId"] as! String
                    let idToken = data["tokenForKeys"] as! String
                    data.removeValue(forKey: "tokenForKeys")
                    data.removeValue(forKey: "verifierId")
                let aggTorusKey = try await getAggregateTorusKey(verifier: self.subVerifierDetails.first!.verifier, verifierId: verifierId, idToken: idToken, subVerifierDetails: subVerifier, userData: newData)
                return aggTorusKey
                } catch {
                    os_log("handleSingleIdVerifier err: %s", log: getTorusLogger(log: CASDKLogger.core, type: .error), type: .error, error.localizedDescription)
                    throw error
                }

            }
        throw CASDKError.unknownError

        }

    func handleAndAggregateVerifier(controller: UIViewController?) async throws -> [String: Any] {
        // TODO: implement verifier
        throw CASDKError.methodUnavailable
    }

    func handleOrAggregateVerifier(controller: UIViewController?) async throws -> [String: Any] {
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
    open func getTorusKey(verifier: String, verifierId: String, idToken: String, userData: [String: Any] = [:]) async throws -> [String: Any] {
        let extraParams = ["verifier_id": verifierId] as [String: Any]
        let buffer: Data = try! NSKeyedArchiver.archivedData(withRootObject: extraParams, requiringSecureCoding: false)
        do {
            let nodeDetails = try await getNodeDetailsFromContract(verifier: verifier, verfierID: verifierId)
            let responseFromRetrieveShares = try await torusUtils.retrieveShares(torusNodePubs: nodeDetails.getTorusNodePub(), endpoints: nodeDetails.getTorusNodeEndpoints(), verifier: verifier, verifierId: verifierId, idToken: idToken, extraParams: buffer)
            var data = userData
            data["privateKey"] = responseFromRetrieveShares["privateKey"]
            data["publicAddress"] = responseFromRetrieveShares["publicAddress"]
            return data
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
    open func getAggregateTorusKey(verifier: String, verifierId: String, idToken: String, subVerifierDetails: SubVerifierDetails, userData: [String: Any] = [:]) async throws -> [String: Any] {
        let extraParams = ["verifieridentifier": verifier, "verifier_id": verifierId, "sub_verifier_ids": [subVerifierDetails.verifier], "verify_params": [["verifier_id": verifierId, "idtoken": idToken]]] as [String: Any]
        let buffer: Data = try! NSKeyedArchiver.archivedData(withRootObject: extraParams, requiringSecureCoding: false)
        let hashedOnce = idToken.sha3(.keccak256)
        do {
        let nodeDetails = try await getNodeDetailsFromContract(verifier: verifier, verfierID: verifierId)
            let responseFromRetrieveShares = try await self.torusUtils.retrieveShares(torusNodePubs: nodeDetails.getTorusNodePub(), endpoints: nodeDetails.getTorusNodeEndpoints(), verifier: verifier, verifierId: verifierId, idToken: hashedOnce, extraParams: buffer)
            var data = userData
            data["privateKey"] = responseFromRetrieveShares["privateKey"]
            data["publicAddress"] = responseFromRetrieveShares["publicAddress"]
            return data
        } catch {
            os_log("handleSingleIdVerifier err: %@", log: getTorusLogger(log: CASDKLogger.core, type: .error), type: .error, error.localizedDescription)
            throw error
        }
    }
}
