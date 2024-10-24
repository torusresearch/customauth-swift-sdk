import Foundation

public enum LoginType: String, Equatable, Hashable, Codable {
    case google
    case facebook
    case discord
    case reddit
    case twitch
    case apple
    case github
    case linkedin
    case twitter
    case weibo
    case line
    case email_password
    case email_passwordless
    case sms_passwordless
    case jwt
}
