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
            if let temp = self.subVerifierDetails.first{
                print(temp)
                let sub = try! SubVerifierDetails(dictionary: temp)
                let loginURL = getLoginURLString(svd: sub)
                openURL(url: loginURL)
            }
            break
        case .andAggregateVerifier:
            break
        case .orAggregateVerifier:
            break
        case .singleIdVerifier:
            if let temp = self.subVerifierDetails.first{
                print(temp)
                let sub = try! SubVerifierDetails(dictionary: temp)
                let loginURL = getLoginURLString(svd: sub)
                observeCallback{ url in
                    var responseParameters = [String: String]()
                    if let query = url.query {
                        responseParameters += query.parametersFromQueryString
                    }
                    if let fragment = url.fragment, !fragment.isEmpty {
                        responseParameters += fragment.parametersFromQueryString
                    }

                    if let accessToken = responseParameters["access_token"], let idToken = responseParameters["id_token"]{
                        print(accessToken, idToken)

                        self.getUserInfo(accessToken: accessToken).then{ data -> Promise<String> in
                            let email = data["email"] as! String
                            return (self.torusUtils?.retreiveShares(endpoints: self.endpoints, verifierIdentifier: self.aggregateVerifierName, verifierParams: [["idtoken":idToken, "verifier_id":email]], subVerifierIds: [sub.subVerifierId], verifierId: email))!
                        }.done{ data in
                            print("final private Key", data)
                        }


                    }
                }
                openURL(url: loginURL)
            }
            break
        case .none:
            print("error occured")
        }
    }
}
