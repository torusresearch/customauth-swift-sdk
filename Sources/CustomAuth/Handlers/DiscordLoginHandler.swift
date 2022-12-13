//
//  DiscordLoginHandler.swift
//
//
//  Created by Shubham on 13/11/20.
//

import Foundation

class DiscordLoginHandler: AbstractLoginHandler {
    let loginType: SubVerifierType
    let clientID: String
    let redirectURL: String
    let browserRedirectURL: String?
    let state: String
    var userInfo: [String: Any]?
    let nonce = String.randomString(length: 10)
    let jwtParams: [String: String]
    let defaultParams: [String: String]
    var urlSession: URLSession

    public init(loginType: SubVerifierType = .web, clientID: String, redirectURL: String, browserRedirectURL: String?, jwtParams: [String: String] = [:], urlSession: URLSession = URLSession.shared) {
        self.loginType = loginType
        self.clientID = clientID
        self.redirectURL = redirectURL
        self.jwtParams = jwtParams
        self.browserRedirectURL = browserRedirectURL
        defaultParams = ["scope": "email identify", "response_type": "token"]
        self.urlSession = urlSession

        let tempState = ["nonce": nonce, "redirectUri": self.redirectURL, "redirectToAndroid": "true"]
        let jsonData = try! JSONSerialization.data(withJSONObject: tempState, options: .prettyPrinted)
        state = String(data: jsonData, encoding: .utf8)!.toBase64URL()
    }

    func getUserInfo(responseParameters: [String: String]) async throws -> [String: Any] {
        return try await handleLogin(responseParameters: responseParameters)
    }

    func getLoginURL() -> String {
        // left join
        var tempParams = defaultParams
        tempParams.merge(["redirect_uri": browserRedirectURL ?? redirectURL, "client_id": clientID, "state": state]) { _, new in new }
        tempParams.merge(jwtParams) { _, new in new }

        // Reconstruct URL
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "discord.com"
        urlComponents.path = "/api/oauth2/authorize"
        urlComponents.setQueryItems(with: tempParams)

        return urlComponents.url!.absoluteString
        //      return "https://discord.com/api/oauth2/authorize?response_type=token" + "&client_id=\(self.clientId)&scope=email identify&redirect_uri=\(newRedirectURL)".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }

    func getVerifierFromUserInfo() -> String {
        return userInfo?["id"] as? String ?? ""
    }

    func handleLogin(responseParameters: [String: String]) async throws -> [String: Any] {
        if let accessToken = responseParameters["access_token"] {
            var request = makeUrlRequest(url: "https://discordapp.com/api/users/@me", method: "GET")
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            do {
                let val = try await urlSession.data(for: request)
                let data = try JSONSerialization.jsonObject(with: val.0) as? [String: Any] ?? [:]
                userInfo = data
                var newData: [String: Any] = ["userInfo": userInfo as Any]
                newData["tokenForKeys"] = accessToken
                newData["verifierId"] = getVerifierFromUserInfo()
                return newData
            } catch {
                throw CASDKError.getUserInfoFailed
            }
        } else {
            throw CASDKError.accessTokenNotProvided
        }
    }
}
