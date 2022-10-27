//
//  ViewModel.swift
//  cptest
//
//  Created by Dhruv Jaiswal on 27/10/22.
//  Copyright © 2022 torus. All rights reserved.
//

import Foundation
import CustomAuth

struct User {
    var publicAddress: String
    var privateKey: String
    var userInfo: [String: String]
}

class ViewModel: ObservableObject {
    @Published var user: User?
    @Published var showingAlert: Bool = false
    private var testnetNetworkUrl: String = "https://rpc.ankr.com/eth_ropsten"
    private var customAuth: CustomAuth? {
        didSet {
            triggerLogin()
        }
    }

    func removeUser() {
        user = nil
        customAuth = nil
    }

    func triggerLogin() {
        let vc = UIApplication.shared.keyWindow?.rootViewController
        customAuth?.triggerLogin(controller: vc).done { [weak self] data in
            self?.decodeData(data: data)
        }.catch { err in
            print(err)
            self.showingAlert = true
        }
    }

    func decodeData(data: [String: Any]) {
        guard let privKey = data["privateKey"] as? String,
              let pubAddress = data["publicAddress"] as? String,
              let userInfo = data["userInfo"] as? [String: Any] else { return }
        let dict: [String: String] = userInfo.compactMapValues { $0 as? String }
        user = User(publicAddress: pubAddress, privateKey: privKey, userInfo: dict)
    }
}

extension ViewModel {
    func googlePolygonLogin() {
        let sub = SubVerifierDetails(loginType: .web,
                                     loginProvider: .google,
                                     clientId: "908137525998-fs00a3go5r7fpbntmui4lb8nhuqqtmaa.apps.googleusercontent.com",
                                     verifierName: "polygon-ios-test",
                                     redirectURL: "torus://org.torusresearch.sample/redirect",
                                     browserRedirectURL: "https://scripts.toruswallet.io/redirect.html",
                                     jwtParams: ["prompt": "login"],
                                     urlSession: URLSession.shared)
        customAuth = CustomAuth(aggregateVerifierType: .singleLogin, aggregateVerifierName: "polygon-ios-test", subVerifierDetails: [sub], network: .POLYGON, urlSession: URLSession.shared)
    }

    func googleLogin() {
        let sub = SubVerifierDetails(loginType: .web,
                                     loginProvider: .google,
                                     clientId: "221898609709-obfn3p63741l5333093430j3qeiinaa8.apps.googleusercontent.com",
                                     verifierName: "google-lrc",
                                     redirectURL: "tdsdk://tdsdk/oauthCallback",
                                     browserRedirectURL: "https://scripts.toruswallet.io/redirect.html",
                                     jwtParams: ["prompt": "login"])

        customAuth = CustomAuth(aggregateVerifierType: .singleLogin, aggregateVerifierName: "google-lrc", subVerifierDetails: [sub], factory: CASDKFactory(), network: .ROPSTEN, networkUrl: testnetNetworkUrl)
    }

    func redditLogin() {
        let sub = SubVerifierDetails(loginType: .web,
                                     loginProvider: .reddit,
                                     clientId: "rXIp6g2y3h1wqg",
                                     verifierName: "reddit-shubs",
                                     redirectURL: "tdsdk://tdsdk/oauthCallback",
                                     urlSession: URLSession.shared)
        customAuth = CustomAuth(aggregateVerifierType: .singleLogin, aggregateVerifierName: "reddit-shubs", subVerifierDetails: [sub], factory: CASDKFactory(), network: .ROPSTEN, urlSession: URLSession.shared, networkUrl: testnetNetworkUrl)
    }

    func discordLogin() {
        let sub = SubVerifierDetails(loginType: .web,
                                     loginProvider: .discord,
                                     clientId: "1034724991972954172",
                                     verifierName: "dhruv-discord",
                                     redirectURL: "tdsdk://tdsdk/oauthCallback",
                                     browserRedirectURL: "https://scripts.toruswallet.io/redirect.html",
                                     urlSession: URLSession.shared)
        customAuth = CustomAuth(aggregateVerifierType: .singleLogin, aggregateVerifierName: "dhruv-discord", subVerifierDetails: [sub], factory: CASDKFactory(), network: .ROPSTEN, urlSession: URLSession.shared, networkUrl: testnetNetworkUrl)
    }

    func facebookLogin() {
        let sub = SubVerifierDetails(loginType: .web,
                                     loginProvider: .facebook,
                                     clientId: "659561074900150",
                                     verifierName: "facebook-shubs",
                                     redirectURL: "tdsdk://tdsdk/oauthCallback",
                                     browserRedirectURL: "https://scripts.toruswallet.io/redirect.html",
                                     urlSession: URLSession.shared)

        customAuth = CustomAuth(aggregateVerifierType: .singleLogin, aggregateVerifierName: "facebook-shubs", subVerifierDetails: [sub], factory: CASDKFactory(), network: .ROPSTEN, urlSession: URLSession.shared, networkUrl: testnetNetworkUrl)
    }

    func twitchLogin() {
        let sub = SubVerifierDetails(loginType: .web,
                                     loginProvider: .twitch,
                                     clientId: "p560duf74b2bidzqu6uo0b3ot7qaao",
                                     verifierName: "twitch-shubs",
                                     redirectURL: "tdsdk://tdsdk/oauthCallback",
                                     urlSession: URLSession.shared)
        customAuth = CustomAuth(aggregateVerifierType: .singleLogin, aggregateVerifierName: "twitch-shubs", subVerifierDetails: [sub], factory: CASDKFactory(), network: .ROPSTEN, urlSession: URLSession.shared, networkUrl: testnetNetworkUrl)
    }

    func twitterLogin() {
        let sub = SubVerifierDetails(loginType: .web,
                                     loginProvider: .twitter,
                                     clientId: "A7H8kkcmyFRlusJQ9dZiqBLraG2yWIsO",
                                     verifierName: "torus-auth0-twitter-lrc",
                                     redirectURL: "tdsdk://tdsdk/oauthCallback",
                                     jwtParams: ["domain": "torus-test.auth0.com", "connection": "twitter"],
                                     urlSession: URLSession.shared)

        customAuth = CustomAuth(aggregateVerifierType: .singleLogin, aggregateVerifierName: "torus-auth0-twitter-lrc", subVerifierDetails: [sub], factory: CASDKFactory(), network: .ROPSTEN, urlSession: URLSession.shared, networkUrl: testnetNetworkUrl)
    }

    func githubLogin() {
        let sub = SubVerifierDetails(loginType: .web,
                                     loginProvider: .github,
                                     clientId: "PC2a4tfNRvXbT48t89J5am0oFM21Nxff",
                                     verifierName: "torus-auth0-github-lrc",
                                     redirectURL: "tdsdk://tdsdk/oauthCallback",
                                     jwtParams: ["domain": "torus-test.auth0.com", "connection": "github"],
                                     urlSession: URLSession.shared)

        customAuth = CustomAuth(aggregateVerifierType: .singleLogin, aggregateVerifierName: "torus-auth0-github-lrc", subVerifierDetails: [sub], factory: CASDKFactory(), network: .ROPSTEN, urlSession: URLSession.shared, networkUrl: testnetNetworkUrl)
    }

    func linkedinLogin() {
        let sub = SubVerifierDetails(loginType: .web,
                                     loginProvider: .linkedin,
                                     clientId: "59YxSgx79Vl3Wi7tQUBqQTRTxWroTuoc",
                                     verifierName: "torus-auth0-linkedin-lrc",
                                     redirectURL: "tdsdk://tdsdk/oauthCallback",
                                     jwtParams: ["domain": "torus-test.auth0.com", "connection": "linkedin"],
                                     urlSession: URLSession.shared)

        customAuth = CustomAuth(aggregateVerifierType: .singleLogin, aggregateVerifierName: "torus-auth0-linkedin-lrc", subVerifierDetails: [sub], factory: CASDKFactory(), network: .ROPSTEN, urlSession: URLSession.shared, networkUrl: testnetNetworkUrl)
    }

    func appleLogin() {
        let sub = SubVerifierDetails(loginType: .web,
                                     loginProvider: .apple,
                                     clientId: "m1Q0gvDfOyZsJCZ3cucSQEe9XMvl9d9L",
                                     verifierName: "torus-auth0-apple-lrc",
                                     redirectURL: "tdsdk://tdsdk/oauthCallback",
                                     jwtParams: ["domain": "torus-test.auth0.com", "connection": "apple"],
                                     urlSession: URLSession.shared)

        customAuth = CustomAuth(aggregateVerifierType: .singleLogin, aggregateVerifierName: "torus-auth0-apple-lrc", subVerifierDetails: [sub], factory: CASDKFactory(), network: .ROPSTEN, urlSession: URLSession.shared, networkUrl: testnetNetworkUrl)
    }

    func emailPasswordlessLogin() {
        let sub = SubVerifierDetails(loginType: .web,
                                     loginProvider: .jwt,
                                     clientId: "P7PJuBCXIHP41lcyty0NEb7Lgf7Zme8Q",
                                     verifierName: "torus-auth0-email-passwordless",
                                     redirectURL: "tdsdk://tdsdk/oauthCallback",
                                     jwtParams: ["domain": "torus-test.auth0.com", "verifier_id_field": "name"],
                                     urlSession: URLSession.shared)

        customAuth = CustomAuth(aggregateVerifierType: .singleLogin, aggregateVerifierName: "torus-auth0-email-passwordless", subVerifierDetails: [sub], factory: CASDKFactory(), network: .ROPSTEN, urlSession: URLSession.shared, networkUrl: testnetNetworkUrl)
    }

    func kakaoLogin() {
        let sub = SubVerifierDetails(loginType: .web,
                                     loginProvider: .kakao,
                                     clientId: "wpkcc7alGJjEgjaL6q5AWRqgRWHFsdTL",
                                     verifierName: "torus-auth0-kakao-lrc",
                                     redirectURL: "tdsdk://tdsdk/oauthCallback",
                                     jwtParams: ["domain": "torus-test.auth0.com"],
                                     urlSession: URLSession.shared)

        customAuth = CustomAuth(aggregateVerifierType: .singleLogin, aggregateVerifierName: "torus-auth0-kakao-lrc", subVerifierDetails: [sub], factory: CASDKFactory(), network: .ROPSTEN, urlSession: URLSession.shared, networkUrl: testnetNetworkUrl)
    }

    func weiboLogin() {
        let sub = SubVerifierDetails(loginType: .web,
                                     loginProvider: .apple,
                                     clientId: "dhFGlWQMoACOI5oS5A1jFglp772OAWr1",
                                     verifierName: "torus-auth0-weibo-lrc",
                                     redirectURL: "tdsdk://tdsdk/oauthCallback",
                                     jwtParams: ["domain": "torus-test.auth0.com"],
                                     urlSession: URLSession.shared)

        customAuth = CustomAuth(aggregateVerifierType: .singleLogin, aggregateVerifierName: "torus-auth0-weibo-lrc", subVerifierDetails: [sub], factory: CASDKFactory(), network: .ROPSTEN, urlSession: URLSession.shared, networkUrl: testnetNetworkUrl)
    }

    func wechatLogin() {
        let sub = SubVerifierDetails(loginType: .web,
                                     loginProvider: .wechat,
                                     clientId: "cewDD3i6F1vtHeV1KIbaxUZ8vJQjJZ8V",
                                     verifierName: "torus-auth0-wechat-lrc",
                                     redirectURL: "tdsdk://tdsdk/oauthCallback",
                                     jwtParams: ["domain": "torus-test.auth0.com"],
                                     urlSession: URLSession.shared)

        customAuth = CustomAuth(aggregateVerifierType: .singleLogin, aggregateVerifierName: "torus-auth0-wechat-lrc", subVerifierDetails: [sub], factory: CASDKFactory(), network: .ROPSTEN, urlSession: URLSession.shared, networkUrl: testnetNetworkUrl)
    }

    func googleDeepLinkFlowLogin() {
        let sub = SubVerifierDetails(loginType: .installed,
                                     loginProvider: .google,
                                     clientId: "238941746713-vfap8uumijal4ump28p9jd3lbe6onqt4.apps.googleusercontent.com",
                                     verifierName: "google-ios",
                                     redirectURL: "com.googleusercontent.apps.238941746713-vfap8uumijal4ump28p9jd3lbe6onqt4:/oauthredirect",
                                     urlSession: URLSession.shared)
        customAuth = CustomAuth(aggregateVerifierType: .singleIdVerifier, aggregateVerifierName: "multigoogle-torus", subVerifierDetails: [sub], factory: CASDKFactory(), network: .ROPSTEN, urlSession: URLSession.shared, networkUrl: testnetNetworkUrl)
    }
}
