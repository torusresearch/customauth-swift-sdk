//
//  ContentView.swift
//  TorusDirectSDKDemo
//
//  Created by Shubham on 24/4/20.
//  Copyright © 2020 Shubham. All rights reserved.
//

import SwiftUI
import TorusSwiftDirectSDK
import SafariServices

struct ContentView: View {
    let googleURL  = "https://accounts.google.com/o/oauth2/v2/auth?response_type=token+id_token&client_id=238941746713-qqe4a7rduuk256d8oi5l0q34qtu9gpfg.apps.googleusercontent.com&nonce=123&redirect_uri=https://backend.relayer.dev.tor.us/redirect&scope=profile+email+openid"
    @State var showSafari = false
    
    var body: some View {
        Button(action: {
            if let url = URL(string: self.googleURL) {
                let fd = TorusSwiftDirectSDK()
                SafariView(url: url)
                self.showSafari = true
                // fd.openURL(url: self.googleURL)
            }
        }, label: {
            Text("Google Login")
        }).sheet(isPresented: $showSafari) {
                SafariView(url:URL(string: self.googleURL)!)
        }
    }
}

struct SafariView: UIViewControllerRepresentable {
    typealias UIViewControllerType = SFSafariViewController
    
    var url: URL?
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        return SFSafariViewController(url: url!)
    }
    
    func updateUIViewController(_ safariViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
