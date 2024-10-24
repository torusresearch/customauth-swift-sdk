import Foundation

public class HashParams: Codable {
    public let access_token: String
    public let id_token: String?

    public init(access_token: String, id_token: String? = nil) {
        self.access_token = access_token
        self.id_token = id_token
    }
}
