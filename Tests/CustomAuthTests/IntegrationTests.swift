//
//  File.swift
//
//
//  Created by Shubham on 5/10/21.
//

@testable import CustomAuth
import Foundation
import JWTKit
import XCTest

final class IntegrationTests: XCTestCase {
    static var sdk: CustomAuth?
    var sub: SubVerifierDetails!

    override func setUp() {
        super.setUp()
        let sub = SubVerifierDetails(loginType: .web,
                                     loginProvider: .google,
                                     clientId: "221898609709-obfn3p63741l5333093430j3qeiinaa8.apps.googleusercontent.com",
                                     verifierName: "google-lrc",
                                     redirectURL: "com.googleusercontent.apps.238941746713-vfap8uumijal4ump28p9jd3lbe6onqt4:/oauthredirect",
                                     browserRedirectURL: "https://scripts.toruswallet.io/redirect.html")

        IntegrationTests.sdk = CustomAuth(aggregateVerifierType: .singleLogin, aggregateVerifierName: "torus-test-ios-public", subVerifierDetails: [sub], network: .POLYGON)
    }

    func test_getTorusKey() async {
        let TORUS_TEST_VERIFIER = "torus-test-health"
        // let TORUS_TEST_VERIFIER =  "torus-google-dhruv-test"
        let exp1 = XCTestExpectation(description: "Should be able to get key")
        let email = "hello@tor.us"
        let jwt = try! generateIdToken(email: email)
        do{
        let data = try await IntegrationTests.sdk?.getTorusKey(verifier: TORUS_TEST_VERIFIER, verifierId: email, idToken: jwt)
            XCTAssertEqual(data?["publicAddress"] as! String, "0x8AA6C8ddCD868873120aA265Fc63E3a2180375BA")
            exp1.fulfill()
        }catch {
            XCTFail(error.localizedDescription)
        }
        wait(for: [exp1], timeout: 15)
    }
}

// JWT payload structure.
struct TestPayload: JWTPayload, Equatable {
    enum CodingKeys: String, CodingKey {
        case subject = "sub"
        case expiration = "exp"
        case isAdmin = "admin"
        case emailVerified = "email_verified"
        case issuer = "iss"
        case iat
        case email
        case audience = "aud"
    }

    var subject: SubjectClaim
    var expiration: ExpirationClaim
    var audience: AudienceClaim
    var isAdmin: Bool
    let emailVerified: Bool
    var issuer: IssuerClaim
    var iat: IssuedAtClaim
    var email: String

    // call its verify method.
    func verify(using signer: JWTSigner) throws {
        try expiration.verifyNotExpired()
    }
}

func generateRandomEmail(of length: Int) -> String {
    let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    var s = ""
    for _ in 0 ..< length {
        s.append(letters.randomElement()!)
    }
    return s + "@gmail.com"
}

func generateIdToken(email: String) throws -> String {
    let verifierPrivateKeyForSigning =
        """
        -----BEGIN PRIVATE KEY-----
        MEECAQAwEwYHKoZIzj0CAQYIKoZIzj0DAQcEJzAlAgEBBCCD7oLrcKae+jVZPGx52Cb/lKhdKxpXjl9eGNa1MlY57A==
        -----END PRIVATE KEY-----
        """

    do {
        let signers = JWTSigners()
        let keys = try ECDSAKey.private(pem: verifierPrivateKeyForSigning)
        signers.use(.es256(key: keys))

        // Parses the JWT and verifies its signature.
        let today = Date()
        let modifiedDate = Calendar.current.date(byAdding: .hour, value: 1, to: today)!

        let emailComponent = email.components(separatedBy: "@")[0]
        let subject = "email|" + emailComponent

        let payload = TestPayload(subject: SubjectClaim(stringLiteral: subject), expiration: ExpirationClaim(value: modifiedDate), audience: "torus-key-test", isAdmin: false, emailVerified: true, issuer: "torus-key-test", iat: IssuedAtClaim(value: Date()), email: email)
        let jwt = try signers.sign(payload)
        return jwt
    } catch {
        print(error)
        throw error
    }
}
