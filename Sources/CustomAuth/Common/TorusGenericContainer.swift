import Foundation

public class TorusGenericContainer: Codable {
    public let params: [String: String]

    init(params: [String: String]) {
        self.params = params
    }
}
