import Foundation
import TorusUtils

public class TorusHybridAggregateLoginResponse: Codable {
    public let singleLogin: TorusAggregateLoginResponse
    public let aggregateLogins: [TorusKey]

    public init(singleLogin: TorusAggregateLoginResponse, aggregateLogins: [TorusKey]) {
        self.singleLogin = singleLogin
        self.aggregateLogins = aggregateLogins
    }
}
