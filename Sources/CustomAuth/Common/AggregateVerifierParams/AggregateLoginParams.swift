import Foundation

public class AggregateLoginParams: Codable {
    public let aggregateVerifierType: AggregateVerifierType
    public let verifierIdentifier: String
    public let subVerifierDetailsArray: [SingleLoginParams]

    public init(aggregateVerifierType: AggregateVerifierType, verifierIdentifier: String, subVerifierDetailsArray: [SingleLoginParams]) {
        self.aggregateVerifierType = aggregateVerifierType
        self.verifierIdentifier = verifierIdentifier
        self.subVerifierDetailsArray = subVerifierDetailsArray
    }
}
