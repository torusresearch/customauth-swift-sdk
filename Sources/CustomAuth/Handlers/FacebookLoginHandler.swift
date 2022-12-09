//
//  GoogleLoginHandler.swift
//
//
//  Created by Shubham on 13/11/20.
//

import Foundation

class FacebookLoginHandler: AbstractLoginHandler {
    let loginType: SubVerifierType
    let clientID: String
    let redirectURL: String
    let browserRedirectURL: String?
    let nonce = String.randomString(length: 10)
    let state: String
    var userInfo: [String: Any]?
    let jwtParams: [String: String]
    let defaultParams: [String: String]
    var urlSession: URLSession

    public init(loginType: SubVerifierType = .web, clientID: String, redirectURL: String, browserRedirectURL: String?, jwtParams: [String: String] = [:], urlSession: URLSession = URLSession.shared) {
        self.loginType = loginType
        self.clientID = clientID
        self.redirectURL = redirectURL
        self.jwtParams = jwtParams
        self.browserRedirectURL = browserRedirectURL
        self.defaultParams = ["scope": "public_profile email", "response_type": "token"]
        self.urlSession = urlSession

        let tempState = ["nonce": self.nonce, "redirectUri": self.redirectURL, "redirectToAndroid": "true"]
        let jsonData = try! JSONSerialization.data(withJSONObject: tempState, options: .prettyPrinted)
        self.state =  String(data: jsonData, encoding: .utf8)!.toBase64URL()
    }

    func getUserInfo(responseParameters: [String: String]) async throws -> [String: Any] {
        return try await self.handleLogin(responseParameters: responseParameters)
    }

    func getLoginURL() -> String {
        // left join
        var tempParams = self.defaultParams
        tempParams.merge(["redirect_uri": self.browserRedirectURL ?? self.redirectURL, "client_id": self.clientID, "state": self.state]) {(_, new ) in new}
        tempParams.merge(self.jwtParams) {(_, new ) in new}

        // Reconstruct URL
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "www.facebook.com"
        urlComponents.path = "/v6.0/dialog/oauth"
        urlComponents.setQueryItems(with: tempParams)

        return urlComponents.url!.absoluteString
        //       return "https://www.facebook.com/v6.0/dialog/oauth?response_type=token&client_id=\(self.clientId)" + "&state=random&scope=public_profile email&redirect_uri=\(newRedirectURL)".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }

    func getVerifierFromUserInfo() -> String {
        return self.userInfo?["id"] as? String ?? ""
    }

    func handleLogin(responseParameters: [String: String]) async throws -> [String: Any] {

        if let accessToken = responseParameters["access_token"] {
            var request = makeUrlRequest(url: "https://graph.facebook.com/me?fields=name,email,picture.type(large)", method: "GET")
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            do {
            let val = try await self.urlSession.data(for: request)
            let data = try JSONSerialization.jsonObject(with: val.0) as? [String: Any] ?? [:]
                self.userInfo = data
                var newData: [String: Any] = ["userInfo": self.userInfo as Any]
                newData["tokenForKeys"] = accessToken
                newData["verifierId"] = self.getVerifierFromUserInfo()
               return newData
            } catch {
                throw CASDKError.getUserInfoFailed
            }
        } else {
            throw CASDKError.accessTokenNotProvided
        }
    }

}
