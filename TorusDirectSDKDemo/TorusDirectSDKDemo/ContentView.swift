//
//  ContentView.swift
//  TorusDirectSDKDemo
//
//  Created by Shubham on 24/4/20.
//  Copyright © 2020 Shubham. All rights reserved.
//

import SwiftUI
import TorusSwiftDirectSDK
import PromiseKit
import SafariServices

struct ContentView: View {
    
    @State var showSafari = false
    
    var body: some View {
        NavigationView{
            List {
                Section(header: Text("Single Logins")) {
                    Button(action: {
                        let subVerifierDetails = [["clientId": "238941746713-qqe4a7rduuk256d8oi5l0q34qtu9gpfg.apps.googleusercontent.com",
                                                   "typeOfLogin": "google",
                                                   "verifier": "google-shubs",
                                                   "redirectURL": "https://backend.relayer.dev.tor.us/redirect"]]
                        let tdsdk = TorusSwiftDirectSDK(aggregateVerifierType: "single_login", aggregateVerifierName: "google-shubs", subVerifierDetails: subVerifierDetails)
                        tdsdk.triggerLogin().done{ data in
                            print("contentview", data)
                        }.catch{ err in
                            print(err)
                        }
                    }, label: {
                        Text("Google Login")
                    })
                    
                    Button(action: {
                        let subverifierDiscord = [["clientId": "rXIp6g2y3h1wqg", "typeOfLogin": "reddit", "verifier":"reddit-shubs"]]
                        let tdsdk = TorusSwiftDirectSDK(aggregateVerifierType: "single_login", aggregateVerifierName: "reddit-shubs", subVerifierDetails: subverifierDiscord)
                        tdsdk.triggerLogin().done{ data in
                            print("contentview", data)
                        }.catch{ err in
                            print(err)
                        }
                    }, label: {
                        Text("Reddit Login")
                    })
                    
                    Button(action: {
                        let subverifierDiscord = [["clientId": "700259843063152661", "typeOfLogin": "discord", "verifier":"discord-shubs"]]
                        let tdsdk = TorusSwiftDirectSDK(aggregateVerifierType: "single_login", aggregateVerifierName: "discord-shubs", subVerifierDetails: subverifierDiscord)
                        tdsdk.triggerLogin().done{ data in
                            print("contentview", data)
                        }.catch{ err in
                            print(err)
                        }
                    }, label: {
                        Text("Discord Login")
                    })
                    
                    Button(action: {
                        let subverifierDiscord = [["clientId": "659561074900150", "typeOfLogin": "facebook", "verifier":"facebook-shubs"]]
                        let tdsdk = TorusSwiftDirectSDK(aggregateVerifierType: "single_login", aggregateVerifierName: "facebook-shubs", subVerifierDetails: subverifierDiscord)
                        tdsdk.triggerLogin().done{ data in
                            print("contentview", data)
                        }.catch{ err in
                            print(err)
                        }
                    }, label: {
                        Text("Facebook Login")
                    })
                    
                    Button(action: {
                        let subverifierDiscord = [["clientId": "p560duf74b2bidzqu6uo0b3ot7qaao", "typeOfLogin": "twitch", "verifier":"twitch-shubs"]]
                        let tdsdk = TorusSwiftDirectSDK(aggregateVerifierType: "single_login", aggregateVerifierName: "twitch-shubs", subVerifierDetails: subverifierDiscord)
                        tdsdk.triggerLogin().done{ data in
                            print("contentview", data)
                        }.catch{ err in
                            print(err)
                        }
                    }, label: {
                        Text("Twitch Login")
                    })
                }
               
                Section(header: Text("Single ID verifier")){
                    Button(action: {
                        let subVerifierDetails = [["clientId": "238941746713-qqe4a7rduuk256d8oi5l0q34qtu9gpfg.apps.googleusercontent.com",
                                                   "typeOfLogin": "google",
                                                   "verifier": "google-shubs"]]
                        let tdsdk = TorusSwiftDirectSDK(aggregateVerifierType: "single_id_verifier", aggregateVerifierName: "google-google", subVerifierDetails: subVerifierDetails)
                        tdsdk.triggerLogin().done{ data in
                            print("contentview", data)
                        }.catch{ err in
                            print(err)
                        }
                    }, label: {
                        Text("Google Login")
                    })
                }
                
            }.navigationBarTitle(Text("DirectAuth app"))
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
