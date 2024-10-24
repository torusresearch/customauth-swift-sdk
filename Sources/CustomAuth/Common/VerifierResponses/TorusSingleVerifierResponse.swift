import Foundation

public class TorusSingleVerifierResponse: Codable {
    public let userInfo: UserInfo
    public let loginResponse: LoginWindowResponse

    public init(userInfo: UserInfo, loginResponse: LoginWindowResponse) {
        self.userInfo = userInfo
        self.loginResponse = loginResponse
    }
}
