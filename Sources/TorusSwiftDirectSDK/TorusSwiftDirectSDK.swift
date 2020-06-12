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

@available(iOS 11.0, *)
open class TorusSwiftDirectSDK{
    
    let torusUtils : TorusUtils
    let endpoints = ["https://lrc-test-13-a.torusnode.com/jrpc", "https://lrc-test-13-b.torusnode.com/jrpc", "https://lrc-test-13-c.torusnode.com/jrpc", "https://lrc-test-13-d.torusnode.com/jrpc", "https://lrc-test-13-e.torusnode.com/jrpc"]
    let aggregateVerifierType : verifierTypes?
    let aggregateVerifierName : String
    let subVerifierDetails : [SubVerifierDetails]
    var observer: NSObjectProtocol?
    
    public init(aggregateVerifierType: verifierTypes, aggregateVerifierName: String, subVerifierDetails: [SubVerifierDetails]){
        torusUtils = TorusUtils()
        self.aggregateVerifierName = aggregateVerifierName
        self.aggregateVerifierType = aggregateVerifierType
        self.subVerifierDetails = subVerifierDetails
    }
    
    
    public func triggerLogin() -> Promise<String>{
        switch self.aggregateVerifierType{
        case .singleLogin:
            return handleSingleLogins()
        case .andAggregateVerifier:
            return handleAndAggregateVerifier()
        case .orAggregateVerifier:
            return handleOrAggregateVerifier()
        case .singleIdVerifier:
            return handleSingleIdVerifier()
        case .none:
            return Promise<String>.value("nil")
        }
    }
    
    func handleSingleLogins() -> Promise<String>{
        let (tempPromise, seal) = Promise<String>.pending()
        if let subVerifier = self.subVerifierDetails.first{
            // print(temp)
            // let subVerifier = try! SubVerifierDetails(dictionary: temp)
            let loginURL = subVerifier.getLoginURL()
            observeCallback{ url in
                print(url)
                var responseParameters = [String: String]()
                if let query = url.query {
                    responseParameters += query.parametersFromQueryString
                }
                if let fragment = url.fragment, !fragment.isEmpty {
                    responseParameters += fragment.parametersFromQueryString
                }
                
                subVerifier.getUserInfo(responseParameters: responseParameters).then{ data -> Promise<String> in
                    let verifierId = data["verifierId"] as! String
                    let idToken = data["tokenForKeys"] as! String
                    let extraParams = ["verifieridentifier": self.aggregateVerifierName, "verifier_id":verifierId] as [String : Any]
                    let buffer: Data = try! NSKeyedArchiver.archivedData(withRootObject: extraParams, requiringSecureCoding: false)
                    
                    return self.torusUtils.retrieveShares(endpoints: self.endpoints, verifierIdentifier: self.aggregateVerifierName, verifierId: verifierId, idToken: idToken, extraParams: buffer)
                }.done{data in
                    seal.fulfill(data)
                }.catch{err in
                    print("err in ", err)
                    seal.reject(err)
                }
            }
            openURL(url: loginURL) // Open in external safari
        }
        return tempPromise
    }
    
    func handleSingleIdVerifier() -> Promise<String>{
        let (tempPromise, seal) = Promise<String>.pending()
        if let subVerifier = self.subVerifierDetails.first{
            // print(temp)
            //let subVerifier = try! SubVerifierDetails(dictionary: temp)
            let loginURL = subVerifier.getLoginURL()
            observeCallback{ url in
                var responseParameters = [String: String]()
                if let query = url.query {
                    responseParameters += query.parametersFromQueryString
                }
                if let fragment = url.fragment, !fragment.isEmpty {
                    responseParameters += fragment.parametersFromQueryString
                }
                
                subVerifier.getUserInfo(responseParameters: responseParameters).then{ data -> Promise<String> in
                    let verifierId = data["verifierId"] as! String
                    let idToken = data["tokenForKeys"] as! String
                    let extraParams = ["verifieridentifier": self.aggregateVerifierName, "verifier_id":verifierId, "sub_verifier_ids":[subVerifier.subVerifierId], "verify_params": [["verifier_id": verifierId, "idtoken": idToken]]] as [String : Any]
                    let dataExample: Data = try! NSKeyedArchiver.archivedData(withRootObject: extraParams, requiringSecureCoding: false)
                    let hashedOnce = idToken.sha3(.keccak256)
                    
                    return self.torusUtils.retrieveShares(endpoints: self.endpoints, verifierIdentifier: self.aggregateVerifierName, verifierId: verifierId, idToken: hashedOnce, extraParams: dataExample)
                }.done{data in
                    seal.fulfill(data)
                }.catch{err in
                    print("err in ", err)
                    seal.reject(err)
                }
            }
            openURL(url: loginURL)
        }
        return tempPromise
    }
    
    func handleAndAggregateVerifier() -> Promise<String>{
        // TODO: implement verifier
        return Promise<String>.value("nil")
    }
    
    func handleOrAggregateVerifier() -> Promise<String>{
        // TODO: implement verifier
        return Promise<String>.value("nil")
    }
}
