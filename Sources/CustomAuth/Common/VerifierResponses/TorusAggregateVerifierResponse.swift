import Foundation

public class TorusAggregateVerifierResponse: Codable {
    public let userInfo: UserInfo
    public let loginResponse: LoginWindowResponse

    public init(userInfo: UserInfo, loginResponse: LoginWindowResponse) {
        self.userInfo = userInfo
        self.loginResponse = loginResponse
    }
}
