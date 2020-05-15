//
//  TorusSwiftDirectSDK class
//  TorusSwiftDirectSDK
//
//  Created by Shubham Rathi on 24/4/2020.
//

import Foundation
import UIKit
import TorusUtils

open class TorusSwiftDirectSDK{
    let torusUtils : TorusUtils?
    let endpoints = ["https://lrc-test-13-a.torusnode.com/jrpc", "https://lrc-test-13-b.torusnode.com/jrpc", "https://lrc-test-13-c.torusnode.com/jrpc", "https://lrc-test-13-d.torusnode.com/jrpc", "https://lrc-test-13-e.torusnode.com/jrpc"]
    var privateKey = ""
    let aggregateVerifierType : verifierTypes?
    let aggregateVerifierName : String
    let subVerifierDetails : [[String:String]]
    
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
            /// Do repective Login
            print("called")

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
                openURL(url: loginURL)
            }
            break
        case .none:
            print("error occured")
        }
    }
    
    public func openURL(url: String) {
        print("opening URL \(url)")
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(URL(string: url)!)
        } else {
            UIApplication.shared.openURL(URL(string: url)!)
        }
    }
    
    func getLoginURLString(svd : SubVerifierDetails) -> String{
        var returnURL : String = ""
        
        switch svd.typeOfLogin{
        case .google:
            returnURL =  "https://accounts.google.com/o/oauth2/v2/auth?response_type=token+id_token&client_id=\(svd.clientId)&nonce=123&redirect_uri=https://backend.relayer.dev.tor.us/redirect&scope=profile+email+openid"
            break
        case .facebook:
            break
        case .twitch:
            break
        case .reddit:
            break
        case .discord:
            break
        case .auth0:
            break
        }
        
        return returnURL
    }
    
    public func handle(url: URL){
        var responseParameters = [String: String]()
        // print(url)
        if let query = url.query {
            responseParameters += query.parametersFromQueryString
        }
        if let fragment = url.fragment, !fragment.isEmpty {
            responseParameters += fragment.parametersFromQueryString
        }
        //        if let idToken = responseParameters["id_token"] {
        //            // print(idToken)
        //            torusUtils.retreiveShares(endpoints: self.endpoints, verifier: "google-shubs", verifierParams: ["verifier_id":"shubham@tor.us"], idToken: idToken).done{ data in
        //                print(data)
        //                self.privateKey = data
        //            }.catch{err in
        //                print(err)
        //            }
        //       }
        
    }
}

enum verifierTypes : String{
    case singleLogin = "single_login"
    case singleIdVerifier = "single_id_verifier"
    case andAggregateVerifier =  "and_aggregate_verifier"
    case orAggregateVerifier = "or_aggregate_verifier"
}

enum LoginProviders : String {
    case google = "google"
    case facebook = "facebook"
    case twitch = "twitch"
    case reddit = "reddit"
    case discord = "discord"
    case auth0 = "auth0"
}

struct SubVerifierDetails {
    let clientId: String
    let typeOfLogin: LoginProviders
    let subVerifierId: String
    
    enum codingKeys: String, CodingKey{
        case clientId
        case typeOfLogin
        case subVerifierId
    }
    
    init(dictionary: [String: String]) throws {
        self.clientId = dictionary["clientId"] ?? ""
        self.typeOfLogin = LoginProviders(rawValue: dictionary["typeOfLogin"] ?? "")!
        self.subVerifierId = dictionary["subVerifierId"] ?? ""
    }
}

