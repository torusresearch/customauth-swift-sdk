import Foundation

internal class State: Codable {
    public var customState: TorusGenericContainer?
    public var instanceId: String
    public var verifier: String
    public var typeOfLogin: String
    public var redirectUri: String
    public var redirectToAndroid: String = "true"
    public var client: String?

    public init(instanceId: String, verifier: String, typeOfLogin: String, redirectUri: String, customState: TorusGenericContainer? = nil, client: String?) {
        self.customState = customState
        self.instanceId = instanceId
        self.verifier = verifier
        self.typeOfLogin = typeOfLogin
        self.redirectUri = redirectUri
        self.client = client
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(customState, forKey: .customState)
        try container.encode(instanceId, forKey: .instanceId)
        try container.encode(verifier, forKey: .verifier)
        try container.encode(typeOfLogin, forKey: .typeOfLogin)
        try container.encode(redirectToAndroid, forKey: .redirectToAndroid)
        try container.encode(redirectUri, forKey: .redirectUri)
        try container.encodeIfPresent(client, forKey: .client)
    }
}
