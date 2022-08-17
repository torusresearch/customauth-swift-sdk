//
//  ContentView.swift
//  CustomAuthDemo
//
//  Created by Shubham on 24/4/20.
//  Copyright © 2020 Shubham. All rights reserved.
//

import CryptoSwift
import CustomAuth
import FetchNodeDetails
import PromiseKit
import SafariServices
import SwiftUI

struct ContentView: View {
    @State var showSafari = false

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Single Logins")) {
                    Group {
                        Button(action: {
                            let sub = SubVerifierDetails(loginType: .web,
                                                         loginProvider: .google,
                                                         clientId: "908137525998-fs00a3go5r7fpbntmui4lb8nhuqqtmaa.apps.googleusercontent.com",
                                                         verifierName: "polygon-ios-test",
                                                         redirectURL: "torus://org.torusresearch.sample/redirect",
                                                         browserRedirectURL: "https://scripts.toruswallet.io/redirect.html",
                                                         jwtParams: ["prompt": "login"],
                                                         urlSession: URLSession.shared)
                            let tdsdk = CustomAuth(aggregateVerifierType: .singleLogin, aggregateVerifierName: "polygon-ios-test", subVerifierDetails: [sub], factory: CASDKFactory(), network: .POLYGON, urlSession: URLSession.shared)
                            let vc = UIApplication.shared.keyWindow?.rootViewController
                            tdsdk.triggerLogin(controller: vc).done { data in
                                print("private key rebuild", data)
                            }.catch { err in
                                print(err)
                            }
                        }, label: {
                            Text("Google Polygon")
                        })

                        Button(action: {
                            let sub = SubVerifierDetails(loginType: .web,
                                                         loginProvider: .google,
                                                         clientId: "221898609709-obfn3p63741l5333093430j3qeiinaa8.apps.googleusercontent.com",
                                                         verifierName: "google-lrc",
                                                         redirectURL: "tdsdk://tdsdk/oauthCallback",
                                                         browserRedirectURL: "https://scripts.toruswallet.io/redirect.html",
                                                         jwtParams: ["prompt": "login"])

                            let tdsdk = CustomAuth(aggregateVerifierType: .singleLogin, aggregateVerifierName: "google-lrc", subVerifierDetails: [sub], factory: CASDKFactory(), network: .ROPSTEN, urlSession: URLSession.shared)
                            tdsdk.triggerLogin().done { data in
                                print("private key rebuild", data)
                            }.catch { err in
                                print(err)
                            }
                        }, label: {
                            Text("Google Login")
                        })

                        Button(action: {
                            let sub = SubVerifierDetails(loginType: .web,
                                                         loginProvider: .reddit,
                                                         clientId: "rXIp6g2y3h1wqg",
                                                         verifierName: "reddit-shubs",
                                                         redirectURL: "tdsdk://tdsdk/oauthCallback",
                                                         urlSession: URLSession.shared)
                            let tdsdk = CustomAuth(aggregateVerifierType: .singleLogin, aggregateVerifierName: "reddit-shubs", subVerifierDetails: [sub], factory: CASDKFactory(), network: .ROPSTEN, urlSession: URLSession.shared)
                            tdsdk.triggerLogin().done { data in
                                print("private key rebuild", data)
                            }.catch { err in
                                print(err)
                            }
                        }, label: {
                            Text("Reddit Login")
                        })

                        Button(action: {
                            let sub = SubVerifierDetails(loginType: .web,
                                                         loginProvider: .discord,
                                                         clientId: "700259843063152661",
                                                         verifierName: "discord-shubs",
                                                         redirectURL: "tdsdk://tdsdk/oauthCallback",
                                                         urlSession: URLSession.shared)
                            let tdsdk = CustomAuth(aggregateVerifierType: .singleLogin, aggregateVerifierName: "discord-shubs", subVerifierDetails: [sub], factory: CASDKFactory(), network: .ROPSTEN, urlSession: URLSession.shared)
                            tdsdk.triggerLogin().done { data in
                                print("private key rebuild", data)
                            }.catch { err in
                                print(err)
                            }
                        }, label: {
                            Text("Discord Login")
                        })

                        Button(action: {
                            let sub = SubVerifierDetails(loginType: .web,
                                                         loginProvider: .facebook,
                                                         clientId: "659561074900150",
                                                         verifierName: "facebook-shubs",
                                                         redirectURL: "tdsdk://tdsdk/oauthCallback",
                                                         browserRedirectURL: "https://scripts.toruswallet.io/redirect.html",
                                                         urlSession: URLSession.shared)

                            let tdsdk = CustomAuth(aggregateVerifierType: .singleLogin, aggregateVerifierName: "facebook-shubs", subVerifierDetails: [sub], factory: CASDKFactory(), network: .ROPSTEN, urlSession: URLSession.shared)
                            tdsdk.triggerLogin().done { data in
                                print("private key rebuild", data)
                            }.catch { err in
                                print(err)
                            }
                        }, label: {
                            Text("Facebook Login")
                        })

                        Button(action: {
                            let sub = SubVerifierDetails(loginType: .web,
                                                         loginProvider: .twitch,
                                                         clientId: "p560duf74b2bidzqu6uo0b3ot7qaao",
                                                         verifierName: "twitch-shubs",
                                                         redirectURL: "tdsdk://tdsdk/oauthCallback",
                                                         urlSession: URLSession.shared)
                            let tdsdk = CustomAuth(aggregateVerifierType: .singleLogin, aggregateVerifierName: "twitch-shubs", subVerifierDetails: [sub], factory: CASDKFactory(), network: .ROPSTEN, urlSession: URLSession.shared)
                            tdsdk.triggerLogin().done { data in
                                print("private key rebuild", data)
                            }.catch { err in
                                print(err)
                            }
                        }, label: {
                            Text("Twitch Login")
                        })

                        Button(action: {
                            let sub = SubVerifierDetails(loginType: .web,
                                                         loginProvider: .twitter,
                                                         clientId: "A7H8kkcmyFRlusJQ9dZiqBLraG2yWIsO",
                                                         verifierName: "torus-auth0-twitter-lrc",
                                                         redirectURL: "tdsdk://tdsdk/oauthCallback",
                                                         jwtParams: ["domain": "torus-test.auth0.com", "connection": "twitter"],
                                                         urlSession: URLSession.shared)

                            let tdsdk = CustomAuth(aggregateVerifierType: .singleLogin, aggregateVerifierName: "torus-auth0-twitter-lrc", subVerifierDetails: [sub], factory: CASDKFactory(), network: .ROPSTEN, urlSession: URLSession.shared)
                            tdsdk.triggerLogin().done { data in
                                print("private key rebuild", data)
                            }.catch { err in
                                print(err)
                            }
                        }, label: {
                            Text("Twitter Login")
                        })

                        Button(action: {
                            let sub = SubVerifierDetails(loginType: .web,
                                                         loginProvider: .github,
                                                         clientId: "PC2a4tfNRvXbT48t89J5am0oFM21Nxff",
                                                         verifierName: "torus-auth0-github-lrc",
                                                         redirectURL: "tdsdk://tdsdk/oauthCallback",
                                                         jwtParams: ["domain": "torus-test.auth0.com", "connection": "github"],
                                                         urlSession: URLSession.shared)

                            let tdsdk = CustomAuth(aggregateVerifierType: .singleLogin, aggregateVerifierName: "torus-auth0-github-lrc", subVerifierDetails: [sub], factory: CASDKFactory(), network: .ROPSTEN, urlSession: URLSession.shared)
                            tdsdk.triggerLogin().done { data in
                                print("private key rebuild", data)
                            }.catch { err in
                                print(err)
                            }
                        }, label: {
                            Text("Github Login")
                        })

                        Button(action: {
                            let sub = SubVerifierDetails(loginType: .web,
                                                         loginProvider: .linkedin,
                                                         clientId: "59YxSgx79Vl3Wi7tQUBqQTRTxWroTuoc",
                                                         verifierName: "torus-auth0-linkedin-lrc",
                                                         redirectURL: "tdsdk://tdsdk/oauthCallback",
                                                         jwtParams: ["domain": "torus-test.auth0.com", "connection": "linkedin"],
                                                         urlSession: URLSession.shared)

                            let tdsdk = CustomAuth(aggregateVerifierType: .singleLogin, aggregateVerifierName: "torus-auth0-linkedin-lrc", subVerifierDetails: [sub], factory: CASDKFactory(), network: .ROPSTEN, urlSession: URLSession.shared)
                            tdsdk.triggerLogin().done { data in
                                print("private key rebuild", data)
                            }.catch { err in
                                print(err)
                            }
                        }, label: {
                            Text("Linkedin Login")
                        })

                        Button(action: {
                            let sub = SubVerifierDetails(loginType: .web,
                                                         loginProvider: .apple,
                                                         clientId: "m1Q0gvDfOyZsJCZ3cucSQEe9XMvl9d9L",
                                                         verifierName: "torus-auth0-apple-lrc",
                                                         redirectURL: "tdsdk://tdsdk/oauthCallback",
                                                         jwtParams: ["domain": "torus-test.auth0.com", "connection": "apple"],
                                                         urlSession: URLSession.shared)

                            let tdsdk = CustomAuth(aggregateVerifierType: .singleLogin, aggregateVerifierName: "torus-auth0-apple-lrc", subVerifierDetails: [sub], factory: CASDKFactory(), network: .ROPSTEN, urlSession: URLSession.shared)
                            tdsdk.triggerLogin().done { data in
                                print("private key rebuild", data)
                            }.catch { err in
                                print(err)
                            }
                        }, label: {
                            Text("Apple Login")
                        })
                    }

                    Group {
                        Button(action: {
                            let sub = SubVerifierDetails(loginType: .web,
                                                         loginProvider: .jwt,
                                                         clientId: "P7PJuBCXIHP41lcyty0NEb7Lgf7Zme8Q",
                                                         verifierName: "torus-auth0-email-passwordless",
                                                         redirectURL: "tdsdk://tdsdk/oauthCallback",
                                                         jwtParams: ["domain": "torus-test.auth0.com", "verifier_id_field": "name"],
                                                         urlSession: URLSession.shared)

                            let tdsdk = CustomAuth(aggregateVerifierType: .singleLogin, aggregateVerifierName: "torus-auth0-email-passwordless", subVerifierDetails: [sub], factory: CASDKFactory(), network: .ROPSTEN, urlSession: URLSession.shared)
                            tdsdk.triggerLogin().done { data in
                                print("private key rebuild", data)
                            }.catch { err in
                                print(err)
                            }
                        }, label: {
                            Text("Email-password Login")
                        })

                        Button(action: {
                            let sub = SubVerifierDetails(loginType: .web,
                                                         loginProvider: .kakao,
                                                         clientId: "wpkcc7alGJjEgjaL6q5AWRqgRWHFsdTL",
                                                         verifierName: "torus-auth0-kakao-lrc",
                                                         redirectURL: "tdsdk://tdsdk/oauthCallback",
                                                         jwtParams: ["domain": "torus-test.auth0.com"],
                                                         urlSession: URLSession.shared)

                            let tdsdk = CustomAuth(aggregateVerifierType: .singleLogin, aggregateVerifierName: "torus-auth0-kakao-lrc", subVerifierDetails: [sub], factory: CASDKFactory(), network: .ROPSTEN, urlSession: URLSession.shared)
                            tdsdk.triggerLogin().done { data in
                                print("private key rebuild", data)
                            }.catch { err in
                                print(err)
                            }
                        }, label: {
                            Text("Kakao Login")
                        })

                        Button(action: {
                            let sub = SubVerifierDetails(loginType: .web,
                                                         loginProvider: .apple,
                                                         clientId: "dhFGlWQMoACOI5oS5A1jFglp772OAWr1",
                                                         verifierName: "torus-auth0-weibo-lrc",
                                                         redirectURL: "tdsdk://tdsdk/oauthCallback",
                                                         jwtParams: ["domain": "torus-test.auth0.com"],
                                                         urlSession: URLSession.shared)

                            let tdsdk = CustomAuth(aggregateVerifierType: .singleLogin, aggregateVerifierName: "torus-auth0-weibo-lrc", subVerifierDetails: [sub], factory: CASDKFactory(), network: .ROPSTEN, urlSession: URLSession.shared)
                            tdsdk.triggerLogin().done { data in
                                print("private key rebuild", data)
                            }.catch { err in
                                print(err)
                            }
                        }, label: {
                            Text("Weibo Login")
                        })

                        Button(action: {
                            let sub = SubVerifierDetails(loginType: .web,
                                                         loginProvider: .wechat,
                                                         clientId: "cewDD3i6F1vtHeV1KIbaxUZ8vJQjJZ8V",
                                                         verifierName: "torus-auth0-wechat-lrc",
                                                         redirectURL: "tdsdk://tdsdk/oauthCallback",
                                                         jwtParams: ["domain": "torus-test.auth0.com"],
                                                         urlSession: URLSession.shared)

                            let tdsdk = CustomAuth(aggregateVerifierType: .singleLogin, aggregateVerifierName: "torus-auth0-wechat-lrc", subVerifierDetails: [sub], factory: CASDKFactory(), network: .ROPSTEN, urlSession: URLSession.shared)
                            tdsdk.triggerLogin().done { data in
                                print("private key rebuild", data)
                            }.catch { err in
                                print(err)
                            }
                        }, label: {
                            Text("Wechat Login")
                        })
                    }
                }

                Section(header: Text("Single ID verifier")) {
                    Button(action: {
                        let sub = SubVerifierDetails(loginType: .installed,
                                                     loginProvider: .google,
                                                     clientId: "238941746713-vfap8uumijal4ump28p9jd3lbe6onqt4.apps.googleusercontent.com",
                                                     verifierName: "google-ios",
                                                     redirectURL: "com.googleusercontent.apps.238941746713-vfap8uumijal4ump28p9jd3lbe6onqt4:/oauthredirect",
                                                     urlSession: URLSession.shared)
                        let tdsdk = CustomAuth(aggregateVerifierType: .singleIdVerifier, aggregateVerifierName: "multigoogle-torus", subVerifierDetails: [sub], factory: CASDKFactory(), network: .ROPSTEN, urlSession: URLSession.shared)
                        tdsdk.triggerLogin().done { data in
                            print("private key rebuild", data)
                        }.catch { err in
                            print(err)
                        }
                    }, label: {
                        Text("Google Login - Deep link flow")
                    })

                    //                    Button(action: {
                    //                        let sub = SubVerifierDetails(loginType: .web,
                    //                                                     loginProvider: .google,
                    //                                                     clientId: "238941746713-qqe4a7rduuk256d8oi5l0q34qtu9gpfg.apps.googleusercontent.com",
                    //                                                     verifierName: "google-shubs",
                    //                                                     redirectURL: "https://backend.relayer.dev.tor.us/demoapp/redirect")
                    //                        let tdsdk = CustomAuth(aggregateVerifierType: .singleIdVerifier, aggregateVerifierName: "multigoogle-torus", subVerifierDetails: [sub])
                    //                        tdsdk.triggerLogin().done{ data in
                    //                            print("private key rebuild", data)
                    //                        }.catch{ err in
                    //                            print(err)
                    //                        }
                    //                    }, label: {
                    //                        Text("Google Login - Universal link flow")
                    //                    })
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
