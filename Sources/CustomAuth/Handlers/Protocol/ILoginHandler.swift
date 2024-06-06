import Foundation

public protocol ILoginHandler {
    var clientId: String { get set }
    var nonce: String { get set }
    var finalUrl: URLComponents { get set }

    func getUserInfo(params: LoginWindowResponse, storageServerUrl: String?) async throws -> TorusVerifierResponse

    func handleLoginWindow(popupFeatures: String?) async throws -> LoginWindowResponse

    func setFinalUrl() throws
}
