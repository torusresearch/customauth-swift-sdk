import Foundation

public class HybridAggregateLoginParams: Codable {
    public let singleLogin: SingleLoginParams
    public let aggregateLoginParams: AggregateLoginParams

    public init(singleLogin: SingleLoginParams, aggregateLoginParams: AggregateLoginParams) {
        self.singleLogin = singleLogin
        self.aggregateLoginParams = aggregateLoginParams
    }
}
