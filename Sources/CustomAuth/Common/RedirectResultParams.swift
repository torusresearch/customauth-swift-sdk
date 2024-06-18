import Foundation

public class RedirectResultParams: Codable {
    public let relaceUrl: Bool
    public let clearLoginDetails: Bool

    public init(relaceUrl: Bool, clearLoginDetails: Bool) {
        self.relaceUrl = relaceUrl
        self.clearLoginDetails = clearLoginDetails
    }
}
