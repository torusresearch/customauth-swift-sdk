import Foundation

public class BaseLoginOptions: Codable {
    public let display: String?
    public let prompt: String?
    public let max_age: String?
    public let ui_locales: String?
    public let id_token_hint: String?
    public let arc_values: String?
    public let scope: String?
    public let audience: String?
    public let connection: String?

    public init(display: String? = nil, prompt: String? = nil, max_age: Int? = nil, ui_locales: String? = nil, id_token_hint: String? = nil, arc_values: String? = nil, scope: String? = nil, audience: String? = nil, connection: String? = nil) {
        self.display = display
        self.prompt = prompt
        self.max_age = max_age != nil ? String(max_age!) : nil
        self.ui_locales = ui_locales
        self.id_token_hint = id_token_hint
        self.arc_values = arc_values
        self.scope = scope
        self.audience = audience
        self.connection = connection
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.display, forKey: .display)
        try container.encodeIfPresent(self.prompt, forKey: .prompt)
        try container.encodeIfPresent(self.max_age, forKey: .max_age)
        try container.encodeIfPresent(self.ui_locales, forKey: .ui_locales)
        try container.encodeIfPresent(self.id_token_hint, forKey: .id_token_hint)
        try container.encodeIfPresent(self.arc_values, forKey: .arc_values)
        try container.encodeIfPresent(self.scope, forKey: .scope)
        try container.encodeIfPresent(self.audience, forKey: .audience)
        try container.encodeIfPresent(self.connection, forKey: .connection)
    }
}
