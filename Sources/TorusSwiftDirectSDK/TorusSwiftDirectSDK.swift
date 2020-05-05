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
    let fd : TorusUtils
    let endpoints = ["https://lrc-test-13-a.torusnode.com/jrpc", "https://lrc-test-13-b.torusnode.com/jrpc", "https://lrc-test-13-c.torusnode.com/jrpc", "https://lrc-test-13-d.torusnode.com/jrpc", "https://lrc-test-13-e.torusnode.com/jrpc"]
    var privateKey = ""
    
    public init(){
        fd = TorusUtils()
    }
    
    public func openURL(url: String) {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(URL(string: url)!)
        } else {
            UIApplication.shared.openURL(URL(string: url)!)
        }
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
        if let idToken = responseParameters["id_token"] {
            // print(idToken)
            fd.retreiveShares(endpoints: self.endpoints, verifier: "google-shubs", verifierParams: ["verifier_id":"shubham@tor.us"], idToken: idToken).done{ data in
                print(data)
                self.privateKey = data
            }.catch{err in
                print(err)
            }
       }

    }
}
