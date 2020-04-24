//
//  ContentView.swift
//  TorusDirectSDKDemo
//
//  Created by Shubham on 24/4/20.
//  Copyright © 2020 Shubham. All rights reserved.
//

import SwiftUI
import OAuthSwift

struct ContentView: View {
    var body: some View {
        Button(action: {
            let oauthswift = OAuth2Swift(
                consumerKey:    "238941746713-qqe4a7rduuk256d8oi5l0q34qtu9gpfg.apps.googleusercontent.com",
                consumerSecret: "1OazY7zW3tn2ziEMqIhKWuW6",
                authorizeUrl:   "https://accounts.google.com/o/oauth2/auth",
                accessTokenUrl: "https://accounts.google.com/o/oauth2/token",
                responseType:   "token"
            )
            
            // in plist define a url schem with: your.bundle.id:
            let _ = oauthswift.authorize(
            withCallbackURL: URL(string: "http://localhost:3050/redirect")!, scope: "https://www.googleapis.com/auth/userinfo.email", state: "") { result in print(result)
            }
        }, label: {
            Text("Google Login")
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
