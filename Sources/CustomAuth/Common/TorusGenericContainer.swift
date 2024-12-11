import Foundation

public class TorusGenericContainer: Codable {
    public let params: [String: String]

    public init(params: [String: String]) {
        self.params = params
    }
}
