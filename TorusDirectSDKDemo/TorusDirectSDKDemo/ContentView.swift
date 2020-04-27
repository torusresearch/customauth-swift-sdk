//
//  ContentView.swift
//  TorusDirectSDKDemo
//
//  Created by Shubham on 24/4/20.
//  Copyright © 2020 Shubham. All rights reserved.
//

import SwiftUI
import TorusSwiftDirectSDK

struct ContentView: View {
    let googleURL  = "https://accounts.google.com/o/oauth2/v2/auth?response_type=token&client_id=238941746713-qqe4a7rduuk256d8oi5l0q34qtu9gpfg.apps.googleusercontent.com&redirect_uri=http://localhost:3050/redirect&scope=https://www.googleapis.com/auth/userinfo.email"
    var body: some View {
        Button(action: {
            if let url = URL(string: self.googleURL) {
                let fd = TorusSwiftDirectSDK()
                fd.openURL(url: self.googleURL)
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
