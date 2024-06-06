import Foundation

public class TorusSubVerifierInfo: Codable {
    public let verifier: String
    public let idToken: String
    public let extraVerifierParams: PassKeyExtraParams?

    public init(verifier: String, idToken: String, extraVerifierParams: PassKeyExtraParams? = nil) {
        self.verifier = verifier
        self.idToken = idToken
        self.extraVerifierParams = extraVerifierParams
    }
}
