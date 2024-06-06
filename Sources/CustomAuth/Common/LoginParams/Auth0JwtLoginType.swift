import Foundation

public enum Auth0JwtLoginType: String, Equatable, Hashable, Codable {
    case apple
    case github
    case linkedin
    case twitter
    case weibo
    case line
    case email_password
    case passwordless
}
