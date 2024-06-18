import Foundation

public enum AuthenticatorTransports: String, Equatable, Hashable, Codable {
    case ble
    case hybrid
    case inside = "internal"
    case nfc
    case usb
}
