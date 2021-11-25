//
//  File.swift
//
//
//  Created by Shubham on 5/10/21.
//

import Foundation
import XCTest
@testable import CustomAuth
import Foundation
import JWTKit

final class IntegrationTests: XCTestCase {
    static var sdk: CustomAuth?
    
    override class func setUp() {
        let sub = SubVerifierDetails(loginType: .web,
                                     loginProvider: .google,
                                     clientId: "221898609709-obfn3p63741l5333093430j3qeiinaa8.apps.googleusercontent.com",
                                     verifierName: "google-lrc",
                                     redirectURL: "com.googleusercontent.apps.238941746713-vfap8uumijal4ump28p9jd3lbe6onqt4:/oauthredirect",
                                     browserRedirectURL: "https://scripts.toruswallet.io/redirect.html")
        
        IntegrationTests.sdk = CustomAuth(aggregateVerifierType: .singleLogin, aggregateVerifierName: "torus-test-ios-public", subVerifierDetails: [sub], network: .ROPSTEN)
    }
    
    func test_getTorusKey(){
        let TORUS_TEST_VERIFIER = "torus-test-ios-public";
        let exp1 = XCTestExpectation(description: "Should be able to get key")
        let email = "hello@tor.us"

        let jwt = try! generateIdToken(email: email)
        IntegrationTests.sdk?.getTorusKey(verifier: TORUS_TEST_VERIFIER, verifierId: email, idToken: jwt).done{data in
            XCTAssertEqual(data["publicAddress"] as! String, "0xF2c682Fc2e053D03Bb91846d6755C3A31ed34C0f")
            exp1.fulfill()
        }.catch{err in
            XCTFail()
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
        case iat = "iat"
        case email = "email"
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
        try self.expiration.verifyNotExpired()
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

func generateIdToken(email: String) throws -> String{
    let verifierPrivateKeyForSigning =
        """
        -----BEGIN PRIVATE KEY-----
        MEECAQAwEwYHKoZIzj0CAQYIKoZIzj0DAQcEJzAlAgEBBCA3pdm53N0jlj3+7st1
        kIxw9aogvHfbq09TlWKRFPGJjA==
        -----END PRIVATE KEY-----
        """
    
    do{
        let signers = JWTSigners()
        let keys = try ECDSAKey.private(pem: verifierPrivateKeyForSigning)
        signers.use(.es256(key: keys))
        
        // Parses the JWT and verifies its signature.
        let today = Date.init()
        let modifiedDate = Calendar.current.date(byAdding: .hour, value: 1, to: today)!
        
        let emailComponent = email.components(separatedBy: "@")[0]
        let subject = "email|"+emailComponent
        
        let payload = TestPayload(subject: SubjectClaim(stringLiteral: subject), expiration: ExpirationClaim(value: modifiedDate), audience: "torus-key-test" , isAdmin: false, emailVerified: true, issuer: "torus-key-test", iat: IssuedAtClaim(value: Date.init()), email: email)
        let jwt = try signers.sign(payload)
        return jwt
    }catch{
        print(error)
        throw error
    }
}
