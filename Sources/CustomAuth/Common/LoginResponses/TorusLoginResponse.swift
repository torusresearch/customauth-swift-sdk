import Foundation
import TorusUtils

public class TorusLoginResponse: Codable {
    public let singleVerifierResponse: TorusSingleVerifierResponse
    public let torusKey: TorusKey

    public init(singleVerifierResponse: TorusSingleVerifierResponse, torusKey: TorusKey) {
        self.singleVerifierResponse = singleVerifierResponse
        self.torusKey = torusKey
    }
}
