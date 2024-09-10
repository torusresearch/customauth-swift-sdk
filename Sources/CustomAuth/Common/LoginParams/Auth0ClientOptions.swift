import Foundation

public class Auth0ClientOptions: BaseLoginOptions {
    public let domain: String?
    public let client_id: String?
    public let redirect_url: String?
    public let leeway: Int?
    public let verifierIdField: String?
    public let isVerifierIdCaseSensitive: String
    public let id_token: String?
    public let access_token: String?
    public let user_info_route: String?
    public var login_hint: String?
    public let flow_type: EmailFlowType?

    private enum CodingKeys: CodingKey {
        case domain,
             client_id,
             redirect_url,
             leeway,
             verifierIdField,
             isVerifierIdCaseSensitive,
             id_token,
             access_token,
             user_info_route,
             login_hint,
             flow_type
    }
    
    public init(display: String? = nil, prompt: String? = nil, max_age: Int? = nil, ui_locales: String? = nil, id_token_hint: String? = nil, arc_values: String? = nil, scope: String? = nil, audience: String? = nil, connection: String? = nil, domain: String? = nil, client_id: String? = nil, redirect_url: String? = nil, leeway: Int? = nil, verifierIdField: String? = nil, isVerifierIdCaseSensitive: Bool = false, id_token: String? = nil, access_token: String? = nil, user_info_route: String? = nil, login_hint: String? = nil, flow_type: EmailFlowType? = nil) {
        
        // This is for convenience in case a full url gets passed in
        // https:// is added back in later when it is constructed from
        // URLComponents()
        var domainHost = domain
        if domain != nil && domain!.starts(with: "https://") {
            domainHost = URL(string: domain!)?.host
        }
        
        self.domain = domainHost
        self.redirect_url = redirect_url
        self.leeway = leeway
        self.verifierIdField = verifierIdField
        self.isVerifierIdCaseSensitive = isVerifierIdCaseSensitive ? "true" : "false"
        self.id_token = id_token
        self.access_token = access_token
        self.user_info_route = user_info_route
        self.client_id = client_id
        self.login_hint = login_hint
        self.flow_type = flow_type

        super.init(display: display, prompt: prompt, max_age: max_age, ui_locales: ui_locales, id_token_hint: id_token_hint, arc_values: arc_values, scope: scope, audience: audience, connection: connection)
    }

    required init(from decoder: any Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    public override func encode(to encoder: any Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.domain, forKey: .domain)
        try container.encodeIfPresent(self.redirect_url, forKey: .redirect_url)
        try container.encodeIfPresent(self.leeway, forKey: .leeway)
        try container.encodeIfPresent(self.verifierIdField, forKey: .verifierIdField)
        try container.encodeIfPresent(self.isVerifierIdCaseSensitive, forKey: .isVerifierIdCaseSensitive)
        try container.encodeIfPresent(self.user_info_route, forKey: .user_info_route)
        try container.encodeIfPresent(self.access_token, forKey: .access_token)
        try container.encodeIfPresent(self.id_token, forKey: .id_token)
        try container.encodeIfPresent(self.client_id, forKey: .client_id)
        try container.encodeIfPresent(self.login_hint, forKey: .login_hint)
        try container.encodeIfPresent(self.flow_type, forKey: .flow_type)
    }
}

public typealias OAuthClientOptions = Auth0ClientOptions
