import Foundation

public class BaseLoginOptions: Codable {
    public let display: String?
    public let prompt: String?
    public let max_age: Int?
    public let ui_locales: String?
    public let id_token_hint: String?
    public let arc_values: String?
    public let scope: String?
    public let audience: String?
    public let connection: String?

    public init(display: String? = nil, prompt: String? = nil, max_age: Int? = nil, ui_locales: String? = nil, id_token_hint: String? = nil, arc_values: String? = nil, scope: String? = nil, audience: String? = nil, connection: String? = nil) {
        self.display = display
        self.prompt = prompt
        self.max_age = max_age
        self.ui_locales = ui_locales
        self.id_token_hint = id_token_hint
        self.arc_values = arc_values
        self.scope = scope
        self.audience = audience
        self.connection = connection
    }
}
