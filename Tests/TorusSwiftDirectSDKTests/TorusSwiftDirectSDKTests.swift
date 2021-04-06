import XCTest
import UIKit
@testable import TorusSwiftDirectSDK

@available(iOS 11.0, *)
final class TorusSwiftDirectSDKTests: XCTestCase {
    func testHandle() {
        let sub = SubVerifierDetails(loginType: .web,
                                     loginProvider: .github,
                                     clientId: "PC2a4tfNRvXbT48t89J5am0oFM21Nxff",
                                     verifierName: "torus-auth0-github-lrc",
                                     redirectURL: "tdsdk://tdsdk/oauthCallback",
                                     jwtParams: ["domain":"torus-test.auth0.com"])
        
        let tdsdk = TorusSwiftDirectSDK(aggregateVerifierType: .singleLogin, aggregateVerifierName: "torus-auth0-github-lrc", subVerifierDetails: [sub], loglevel: .info)
        let loginURL = sub.getLoginURL()
        
        // Open safari and get the idToken
        
    }

    static var allTests = [
        ("testHandle", testHandle),
    ]
}
