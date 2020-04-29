//
//  TorusSwiftDirectSDK class
//  TorusSwiftDirectSDK
//
//  Created by Shubham Rathi on 24/4/2020.
//

import Foundation
import UIKit

open class TorusSwiftDirectSDK{
    public init(){
        
    }
    
    public func openURL(url: String) {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(URL(string: url)!)
        } else {
            UIApplication.shared.openURL(URL(string: url)!)
        }
    }
    
    public func handle(url: URL){
        var responseParameters = [String: String]()
        print(url)
        if let query = url.query {
            responseParameters += query.parametersFromQueryString
        }
        if let fragment = url.fragment, !fragment.isEmpty {
            responseParameters += fragment.parametersFromQueryString
        }
        // print(responseParameters)
        
    }
}

///Facebook
///https://app.tor.us/redirect?#access_token=EAAkTDHpof6sBACEre7tZB3HL2qwGuZC8jDqX5FaqeUmj3UckesKMosK5IwADQVjysZABhZBGEJ4KGr4PYmlYDGVlE37cb2IZCATLbr7pIN0ILMeq6GkTcphDRZCo9ZAPJhEptZAladeAIxWCPqOwR7ht8CBRlvUi0fafpAySgRKNiYqAra5ttJtNju6OyTLAo8WA4HdwNCUPZCAZDZD&data_access_expiration_time=1595911689&expires_in=4311&state=eyJpbnN0YW5jZUlkIjoiSzdPcjZ4dDVwdlRpSHdXaXNLMnV1aGdsVERHcnRCIiwidmVyaWZpZXIiOiJmYWNlYm9vayJ9

/// Reddit
///https://app.tor.us/redirect#access_token=4387799901-rMeeTaTzLvpuj4WILmCY5J6B_yU&token_type=bearer&state=eyJpbnN0YW5jZUlkIjoiSzdPcjZ4dDVwdlRpSHdXaXNLMnV1aGdsVERHcnRCIiwidmVyaWZpZXIiOiJyZWRkaXQifQ%3D%3D&expires_in=3600&scope=identity

/// Twitch
///https://app.tor.us/redirect#access_token=0n039vwihu2002d9didrtjpx44ns21&scope=user%3Aread%3Aemail&state=eyJpbnN0YW5jZUlkIjoiSzdPcjZ4dDVwdlRpSHdXaXNLMnV1aGdsVERHcnRCIiwidmVyaWZpZXIiOiJ0d2l0Y2gifQ%3D%3D&token_type=bearer

/// discord
///https://app.tor.us/redirect#token_type=Bearer&access_token=fRqQcpNRrX0OsYxYjSeOx48GrM7QrG&expires_in=604800&scope=identify+email&state=eyJpbnN0YW5jZUlkIjoiSzdPcjZ4dDVwdlRpSHdXaXNLMnV1aGdsVERHcnRCIiwidmVyaWZpZXIiOiJkaXNjb3JkIn0%3D
