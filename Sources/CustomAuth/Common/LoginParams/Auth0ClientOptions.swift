import Foundation

public class Auth0ClientOptions: BaseLoginOptions {
    public let domain: String?
    public let client_id: String?
    public let redirect_url: String?
    public let leeway: Int?
    public let verifierIdField: String?
    public let isVerifierIdCaseSensitive: Bool
    public let id_token: String?
    public let access_token: String?
    public let user_info_route: String?

    public init(display: String? = nil, prompt: String? = nil, max_age: Int? = nil, ui_locales: String? = nil, id_token_hint: String? = nil, arc_values: String? = nil, scope: String? = nil, audience: String? = nil, connection: String? = nil, domain: String? = nil, client_id: String? = nil, redirect_url: String? = nil, leeway: Int? = nil, verifierIdField: String? = nil, isVerifierIdCaseSensitive: Bool = false, id_token: String? = nil, access_token: String? = nil, user_info_route: String? = nil) {
        self.domain = domain
        self.redirect_url = redirect_url
        self.leeway = leeway
        self.verifierIdField = verifierIdField
        self.isVerifierIdCaseSensitive = isVerifierIdCaseSensitive
        self.id_token = id_token
        self.access_token = access_token
        self.user_info_route = user_info_route
        self.client_id = client_id

        super.init(display: display, prompt: prompt, max_age: max_age, ui_locales: ui_locales, id_token_hint: id_token_hint, arc_values: arc_values, scope: scope, audience: audience, connection: connection)
    }

    required init(from decoder: any Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}
