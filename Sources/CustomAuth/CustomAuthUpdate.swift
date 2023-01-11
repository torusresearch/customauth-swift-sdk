//
//  File.swift
//
//
//  Created by Dhruv Jaiswal on 10/01/23.
//

import FetchNodeDetails
import Foundation
import OSLog
import TorusUtils
import UIKit

extension CustomAuth {
    func updateTriggerLogin(subVerifierDetails: SubVerifierDetails, controller: UIViewController?, modalPresentationStyle: UIModalPresentationStyle = .fullScreen) async throws -> [String: Any] {
        let loginURL = subVerifierDetails.getLoginURL()
        await openURL(url: loginURL, view: controller, modalPresentationStyle: modalPresentationStyle)
        let url = await withUnsafeContinuation({ continuation in
            observeCallback { url in
                continuation.resume(returning: url)
            }
        })

        let responseParameters = parseURL(url: url)
        os_log("ResponseParams after redirect: %@", log: getTorusLogger(log: CASDKLogger.core, type: .info), type: .info, responseParameters)
        do {
            let newData = try await subVerifierDetails.getUserInfo(responseParameters: responseParameters)
            os_log("getUserInfo newData: %@", log: getTorusLogger(log: CASDKLogger.core, type: .info), type: .info, newData)
            var data = newData
            let verifierId = data["verifierId"] as! String
            let idToken = data["tokenForKeys"] as! String
            data.removeValue(forKey: "tokenForKeys")
            data.removeValue(forKey: "verifierId")
            let torusKey = try await updateGetTorusKey(verifier: subVerifierDetails.verifier, verifierId: verifierId, verifierParams: ["verifier_id": verifierId], idToken: idToken)
            return torusKey
        } catch {
            os_log("handleSingleLogin: err: %s", log: getTorusLogger(log: CASDKLogger.core, type: .error), type: .error, error.localizedDescription)
            throw error
        }
    }

    func updateGetTorusKey(verifier: String, verifierId: String, verifierParams: [String: Any], idToken: String) async throws -> [String: Any] {
        let buffer: Data = try! NSKeyedArchiver.archivedData(withRootObject: verifierParams, requiringSecureCoding: false)
        do {
            let nodeDetails = try await getNodeDetailsFromContract(verifier: verifier, verfierID: verifierId)
            let responseFromRetrieveShares = try await torusUtils.retrieveShares(torusNodePubs: nodeDetails.getTorusNodePub(), endpoints: nodeDetails.getTorusNodeEndpoints(), verifier: verifier, verifierId: verifierId, idToken: idToken, extraParams: buffer)
            var data: [String: Any] = [:]
            data["privateKey"] = responseFromRetrieveShares["privateKey"]
            data["publicAddress"] = responseFromRetrieveShares["publicAddress"]
            return data
        } catch {
            os_log("handleSingleLogin: err: %s", log: getTorusLogger(log: CASDKLogger.core, type: .error), type: .error, error.localizedDescription)
            throw error
        }
    }

    func updateGetAggregateTorusKey(verifier: String, verfierId: String, subVerifierInfoArray: [TorusSubVerifierInfo]) async throws -> [String: Any] {
        var setVerifyParamItemArr = [AggregateVerifierParams.VerifierParams]()
        var setSubVerifierIdItemArr = [String]()
        let aggregateVerifierParams: [AggregateVerifierParams] = []
        var aggregateVerifierId: String = ""
        var aggregateIdTokenSeeds: [String] = []
        for i in 0 ... subVerifierInfoArray.count {
            let userInfo = subVerifierInfoArray[i]
            let finalToken: String = userInfo.idToken
            setVerifyParamItemArr.append(.init(verifierId: verfierId, idToken: finalToken))
            setSubVerifierIdItemArr.append(userInfo.verifier)
            aggregateIdTokenSeeds.append(finalToken)
            aggregateVerifierId = verfierId
        }
        aggregateIdTokenSeeds.sort()
        let aggregateTokenString = aggregateIdTokenSeeds.reduce("") { $0 + $1 }
        let aggregateIdToken = String(aggregateTokenString.sha3(.keccak256).dropFirst(2))
        var verifyparamsDict: [[String: String]] = [[:]]
        for i in 0 ... aggregateVerifierParams.count {
            let val = subVerifierInfoArray[i]
            var dict: [String: String] = [:]
            dict["verifier_id"] = val.verifier
            dict["idtoken"] = val.idToken
            verifyparamsDict.append(dict)
        }
        let extraParams = ["verifieridentifier": verifier, "verifier_id": verfierId, "sub_verifier_ids": [setSubVerifierIdItemArr], "verify_params": [verifyparamsDict]] as [String: Any]
        return try await updateGetTorusKey(verifier: verifier, verifierId: verfierId, verifierParams: extraParams, idToken: aggregateIdToken)
    }
}
