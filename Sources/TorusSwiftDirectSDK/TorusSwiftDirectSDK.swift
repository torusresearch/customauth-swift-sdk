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
    let torusUtils : TorusUtils?
    let endpoints = ["https://lrc-test-13-a.torusnode.com/jrpc", "https://lrc-test-13-b.torusnode.com/jrpc", "https://lrc-test-13-c.torusnode.com/jrpc", "https://lrc-test-13-d.torusnode.com/jrpc", "https://lrc-test-13-e.torusnode.com/jrpc"]
    var privateKey = ""
    let aggregateVerifierType : verifierTypes?
    let aggregateVerifierName : String
    let subVerifierDetails : [[String:String]]
    var observer: NSObjectProtocol?

    /// Todo: Make initialiser failable for invalid aggregateVerifierType
    public init(aggregateVerifierType: String, aggregateVerifierName: String, subVerifierDetails: [[String:String]]){
        torusUtils = TorusUtils()
        self.aggregateVerifierName = aggregateVerifierName
        self.aggregateVerifierType = verifierTypes(rawValue: aggregateVerifierType)
        self.subVerifierDetails = subVerifierDetails
    }
    
    
    public func triggerLogin(){
        switch self.aggregateVerifierType{
        case .singleLogin:
            handleSingleLogins()
            break
        case .andAggregateVerifier:
            handleAndAggregateVerifier()
            break
        case .orAggregateVerifier:
            handleOrAggregateVerifier()
            break
        case .singleIdVerifier:
            handleSingleIdVerifier()
            break
        case .none:
            print("error occured")
        }
    }
    
    func handleSingleLogins(){
        if let temp = self.subVerifierDetails.first{
            // print(temp)
            let subVerifier = try! SubVerifierDetails(dictionary: temp)
            let loginURL = subVerifier.typeOfLogin.getLoginURL(clientId: subVerifier.clientId)
            observeCallback{ url in
                print(url)
                var responseParameters = [String: String]()
                if let query = url.query {
                    responseParameters += query.parametersFromQueryString
                }
                if let fragment = url.fragment, !fragment.isEmpty {
                    responseParameters += fragment.parametersFromQueryString
                }
                
                subVerifier.typeOfLogin.getUserInfo(responseParameters: responseParameters).then{ data -> Promise<String> in
                    let verifierId = data["verifierId"] as! String
                    let idToken = data["tokenForKeys"] as! String
                    let extraParams = ["verifieridentifier": self.aggregateVerifierName, "verifier_id":verifierId] as [String : Any]
                    let buffer: Data = try! NSKeyedArchiver.archivedData(withRootObject: extraParams, requiringSecureCoding: false)
                    
                    return (self.torusUtils?.retrieveShares(endpoints: self.endpoints, verifierIdentifier: self.aggregateVerifierName, verifierId: verifierId, idToken: idToken, extraParams: buffer))!
                }.done{ data in
                    print("final private Key", data)
                }.catch{err in
                    print("err in ", err)
                }
                
//                if let accessToken = responseParameters["access_token"], let idToken = responseParameters["id_token"]{
//                    print(accessToken, idToken)
//
//                    subVerifier.typeOfLogin.getUserInfo(accessToken: accessToken).then{ data -> Promise<String> in
//                        let email = data["email"] as! String
//                        let extraParams = ["verifieridentifier": self.aggregateVerifierName, "verifier_id":email] as [String : Any]
//                        let dataExample: Data = try! NSKeyedArchiver.archivedData(withRootObject: extraParams, requiringSecureCoding: false)
//
//                        return (self.torusUtils?.retrieveShares(endpoints: self.endpoints, verifierIdentifier: self.aggregateVerifierName, verifierId: email, idToken: idToken, extraParams: dataExample))!
//                    }.done{ data in
//                        print("final private Key", data)
//                    }.catch{err in
//                        print("err in ", err)
//                    }
//                }
            }
            openURL(url: loginURL) // Open in external safari
        }
    }
    
    func handleSingleIdVerifier(){
        if let temp = self.subVerifierDetails.first{
            // print(temp)
            let subVerifier = try! SubVerifierDetails(dictionary: temp)
            let loginURL = subVerifier.typeOfLogin.getLoginURL(clientId: subVerifier.clientId)
            observeCallback{ url in
                var responseParameters = [String: String]()
                if let query = url.query {
                    responseParameters += query.parametersFromQueryString
                }
                if let fragment = url.fragment, !fragment.isEmpty {
                    responseParameters += fragment.parametersFromQueryString
                }
                
                subVerifier.typeOfLogin.getUserInfo(responseParameters: responseParameters).then{ data -> Promise<String> in
                    let email = data["email"] as! String
                    let idToken = data["id_token"] as! String
                    let extraParams = ["verifieridentifier": self.aggregateVerifierName, "verifier_id":email, "sub_verifier_ids":[subVerifier.subVerifierId], "verify_params": [["verifier_id": email, "idtoken": idToken]]] as [String : Any]
                    let dataExample: Data = try! NSKeyedArchiver.archivedData(withRootObject: extraParams, requiringSecureCoding: false)
                    let hashedOnce = idToken.sha3(.keccak256)
                    
                    return (self.torusUtils?.retrieveShares(endpoints: self.endpoints, verifierIdentifier: self.aggregateVerifierName, verifierId: email, idToken: hashedOnce, extraParams: dataExample))!
                }.done{ data in
                    print("final private Key", data)
                }.catch{err in
                    print("err in ", err)
                }
            }
            openURL(url: loginURL)
        }
    }
    
    func handleAndAggregateVerifier(){
        
    }
    
    func handleOrAggregateVerifier(){
        
    }
}
