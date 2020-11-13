//
//  AbstractLoginHandler.swift
//  
//
//  Created by Shubham on 13/11/20.
//

import Foundation
import PromiseKit

protocol AbstractLoginHandler {
    func getLoginURL() -> String;
    func getVerifierFromUserInfo() -> String;
    func handleLogin(responseParameters: [String:String]) -> Promise<[String:Any]>
}
