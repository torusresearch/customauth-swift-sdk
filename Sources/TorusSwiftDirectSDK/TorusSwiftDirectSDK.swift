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
}
