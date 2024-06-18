import Foundation
import TorusUtils

public class TorusAggregateLoginResponse: Codable {
    public let torusAggregateVerifierResponse: [TorusAggregateVerifierResponse]
    public let torusKey: TorusKey

    public init(torusAggregateVerifierResponse: [TorusAggregateVerifierResponse], torusKey: TorusKey) {
        self.torusAggregateVerifierResponse = torusAggregateVerifierResponse
        self.torusKey = torusKey
    }
}
