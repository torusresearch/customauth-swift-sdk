import AuthenticationServices
#if os(macOS)
    import AppKit
#else
    import UIKit
#endif

internal class AuthenticationManager: NSObject, ASWebAuthenticationPresentationContextProviding {
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        var window: ASPresentationAnchor?
        #if os(macOS)
            window = NSApplication.shared.windows.first { $0.isKeyWindow }
        #else
            window = UIApplication.shared.windows.first { $0.isKeyWindow }
        #endif

        return window ?? ASPresentationAnchor()
    }

    func webAuth(url: URL, callbackURLScheme: String, prefersEphemeralWebBrowserSession: Bool,
                 completion: @escaping (Result<URL, Error>) -> Void) {
        let authSession = ASWebAuthenticationSession(url: url, callbackURLScheme: callbackURLScheme) { url, error in
            if let error = error {
                completion(.failure(error))
            } else if let url = url {
                completion(.success(url))
            }
        }

        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            authSession.presentationContextProvider = self
            authSession.prefersEphemeralWebBrowserSession = prefersEphemeralWebBrowserSession
            authSession.start()
        }
    }

    public func authenticationManagerWrapper(url: URL, callbackURLScheme: String, prefersEphemeralWebBrowserSession: Bool) async throws -> URL {
        return try await withCheckedThrowingContinuation { continuation in
            webAuth(url: url, callbackURLScheme: callbackURLScheme, prefersEphemeralWebBrowserSession: prefersEphemeralWebBrowserSession) { result in
                switch result {
                case let .success(url):
                    continuation.resume(returning: url)
                case let .failure(error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
