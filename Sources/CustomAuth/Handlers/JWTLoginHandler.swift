//
//  File.swift
//
//
//  Created by Shubham on 13/11/20.
//

import Foundation
import JWTDecode
import PromiseKit
import TorusUtils

class JWTLoginHandler: AbstractLoginHandler {
    let loginType: SubVerifierType
    let clientID: String
    let redirectURL: String
    let browserRedirectURL: String?
    var userInfo: [String: Any]?
    let nonce = String.randomString(length: 10)
    let state: String
    let extraQueryParams: [String: String]
    let defaultParams: [String: String]
    let jwtParams: [String: String]
    let connection: LoginProviders
    var urlSession: URLSession

    public init(loginType: SubVerifierType = .web, clientID: String, redirectURL: String, browserRedirectURL: String?, jwtParams: [String: String], extraQueryParams: [String: String] = [:], connection: LoginProviders, urlSession: URLSession = URLSession.shared) {
        self.loginType = loginType
        self.clientID = clientID
        self.redirectURL = redirectURL
        self.extraQueryParams = extraQueryParams
        self.connection = connection
        self.browserRedirectURL = browserRedirectURL
        self.jwtParams = jwtParams
        defaultParams = ["scope": "openid profile email", "response_type": "token id_token", "nonce": nonce]
        self.urlSession = urlSession

        let tempState = ["nonce": nonce, "redirectUri": self.redirectURL, "redirectToAndroid": "true"]
        let jsonData = try! JSONSerialization.data(withJSONObject: tempState, options: .prettyPrinted)
        state = String(data: jsonData, encoding: .utf8)!.toBase64URL()
//        self.state = ["nonce": self.nonce, "redirectUri": self.redirectURL, "redirectToAndroid": "true"].description.toBase64URL()
    }

    func getUserInfo(responseParameters: [String: String]) -> Promise<[String: Any]> {
        return handleLogin(responseParameters: responseParameters)
    }

    func getLoginURL() -> String {
        // left join
        var tempParams = defaultParams
        let paramsToJoin: [String: String] = ["redirect_uri": browserRedirectURL ?? redirectURL, "client_id": clientID, "domain": jwtParams["domain"]!, "state": state]
        tempParams.merge(paramsToJoin) { _, new in new }
        tempParams.merge(extraQueryParams) { _, new in new }

        // Reconstruct URL
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = jwtParams["domain"]
        urlComponents.path = "/authorize"
        urlComponents.setQueryItems(with: tempParams)

        // return string
        return urlComponents.url!.absoluteString
    }

    func getVerifierFromUserInfo() -> String {
        var res: String
        let lowerCased = jwtParams["isVerifierIdCaseSensitive"] ?? "false"

        if jwtParams["verifierIdField"] != nil {
            let field = jwtParams["verifierIdField"]!
            res = userInfo![field] as! String
        } else {
            switch connection {
            case .apple, .weibo, .github, .twitter, .linkedin, .line, .jwt:
                res = userInfo!["sub"] as! String
            case .email_password:
                res = userInfo!["name"] as! String
            default:
                return "verifier not supported"
            }
        }

        if lowerCased == "true" {
            return res.lowercased()
        } else {
            return res
        }
    }

    func handleLogin(responseParameters: [String: String]) -> Promise<[String: Any]> {
        let (tempPromise, seal) = Promise<[String: Any]>.pending()

        // Reconstruct URL
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = jwtParams["domain"]
        urlComponents.path = "/userinfo"

        if let accessToken = responseParameters["access_token"] {
            var request = makeUrlRequest(url: urlComponents.url!.absoluteString, method: "GET")
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

            urlSession.dataTask(.promise, with: request).map {
                try JSONSerialization.jsonObject(with: $0.data) as! [String: Any]
            }.done { data in
                self.userInfo = data
                if responseParameters["error"] != nil {
                    throw responseParameters["error"]!
                }
                var newData: [String: Any] = ["userInfo": self.userInfo as Any]
                newData["tokenForKeys"] = responseParameters["id_token"]
                newData["verifierId"] = self.getVerifierFromUserInfo()
                seal.fulfill(newData)

            }.catch { _ in
                seal.reject(CASDKError.getUserInfoFailed)
            }
        } else if let idToken = responseParameters["id_token"] {
            do {
                let decodedData = try decode(jwt: idToken)
                userInfo = decodedData.body
                var newData: [String: Any] = userInfo!
                newData["tokenForKeys"] = idToken
                newData["verifierId"] = getVerifierFromUserInfo()
                seal.fulfill(newData)
            } catch {
                seal.reject(TorusUtilError.runtime("Invalid ID toke"))
            }
        } else {
            seal.reject(CASDKError.accessTokenNotProvided)
        }

        return tempPromise
    }
}
