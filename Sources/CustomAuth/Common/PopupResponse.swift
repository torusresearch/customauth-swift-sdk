import Foundation

public class PopupResponse: Codable {
    public let hashParams: HashParams
    public let instanceParams: TorusGenericContainer

    public init(hashParams: HashParams, instanceParams: TorusGenericContainer) {
        self.hashParams = hashParams
        self.instanceParams = instanceParams
    }
}
