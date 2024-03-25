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
                    // Group {
                    Button(action: {
                        let sub = SubVerifierDetails(loginType: .web,
                                                     loginProvider: .google,
                                                     clientId: "221898609709-obfn3p63741l5333093430j3qeiinaa8.apps.googleusercontent.com",
                                                     verifier: "google-lrc",
                                                     redirectURL: "tdsdk://tdsdk/oauthCallback",
                                                     browserRedirectURL: "https://scripts.toruswallet.io/redirect.html")

                        let tdsdk = CustomAuth(web3AuthClientId: "221898609709-obfn3p63741l5333093430j3qeiinaa8.apps.googleusercontent.com", aggregateVerifierType: .singleLogin, aggregateVerifier: "google-lrc", subVerifierDetails: [sub], network: .legacy(.TESTNET))
                        Task {
                            do {
                                let loginData = try await tdsdk.triggerLogin().torusKey.finalKeyData!
                                print(loginData)
                            } catch {
                                print("Error occured")
                            }
                        }
                    }, label: {
                        Text("Google Login")
                    })

                    Button(action: {
                        let sub = SubVerifierDetails(loginType: .web,
                                                     loginProvider: .reddit,
                                                     clientId: "rXIp6g2y3h1wqg",
                                                     verifier: "reddit-shubs",
                                                     redirectURL: "tdsdk://tdsdk/oauthCallback")
                        let tdsdk = CustomAuth(web3AuthClientId: "rXIp6g2y3h1wqg", aggregateVerifierType: .singleLogin, aggregateVerifier: "reddit-shubs", subVerifierDetails: [sub], network: .legacy(.TESTNET))
                        Task {
                            do {
                                let loginData = try await tdsdk.triggerLogin().torusKey.finalKeyData!
                                print(loginData)
                            } catch {
                                print("Error occured")
                            }
                        }
                    }, label: {
                        Text("Reddit Login")
                    })

                    Button(action: {
                        let sub = SubVerifierDetails(loginType: .web,
                                                     loginProvider: .discord,
                                                     clientId: "700259843063152661",
                                                     verifier: "discord-shubs",
                                                     redirectURL: "tdsdk://tdsdk/oauthCallback")
                        let tdsdk = CustomAuth(web3AuthClientId: "700259843063152661", aggregateVerifierType: .singleLogin, aggregateVerifier: "discord-shubs", subVerifierDetails: [sub], network: .legacy(.TESTNET))
                        Task {
                            do {
                                let loginData = try await tdsdk.triggerLogin().torusKey.finalKeyData!
                                print(loginData)
                            } catch {
                                print("Error occured")
                            }
                        }
                    }, label: {
                        Text("Discord Login")
                    })

                    Button(action: {
                        let sub = SubVerifierDetails(loginType: .web,
                                                     loginProvider: .facebook,
                                                     clientId: "659561074900150",
                                                     verifier: "facebook-shubs",
                                                     redirectURL: "tdsdk://tdsdk/oauthCallback", browserRedirectURL: "https://scripts.toruswallet.io/redirect.html")

                        let tdsdk = CustomAuth(web3AuthClientId: "221898609709-obfn3p63741l5333093430j3qeiinaa8.apps.googleusercontent.com", aggregateVerifierType: .singleLogin, aggregateVerifier: "facebook-shubs", subVerifierDetails: [sub], network: .legacy(.TESTNET))
                        Task {
                            do {
                                let loginData = try await tdsdk.triggerLogin().torusKey.finalKeyData!
                                print(loginData)
                            } catch {
                                print("Error occured")
                            }
                        }
                    }, label: {
                        Text("Facebook Login")
                    })

                    Button(action: {
                        let sub = SubVerifierDetails(loginType: .web,
                                                     loginProvider: .twitch,
                                                     clientId: "p560duf74b2bidzqu6uo0b3ot7qaao",
                                                     verifier: "twitch-shubs",
                                                     redirectURL: "tdsdk://tdsdk/oauthCallback")
                        let tdsdk = CustomAuth(web3AuthClientId: "p560duf74b2bidzqu6uo0b3ot7qaao", aggregateVerifierType: .singleLogin, aggregateVerifier: "twitch-shubs", subVerifierDetails: [sub], network: .legacy(.TESTNET))
                        Task {
                            do {
                                let loginData = try await tdsdk.triggerLogin().torusKey.finalKeyData!
                                print(loginData)
                            } catch {
                                print("Error occured")
                            }
                        }
                    }, label: {
                        Text("Twitch Login")
                    })

                    Button(action: {
                        let sub = SubVerifierDetails(loginType: .web,
                                                     loginProvider: .twitter,
                                                     clientId: "A7H8kkcmyFRlusJQ9dZiqBLraG2yWIsO",
                                                     verifier: "torus-auth0-twitter-lrc",
                                                     redirectURL: "tdsdk://tdsdk/oauthCallback",
                                                     jwtParams: ["domain": "torus-test.auth0.com"])

                        let tdsdk = CustomAuth(web3AuthClientId: "A7H8kkcmyFRlusJQ9dZiqBLraG2yWIsO", aggregateVerifierType: .singleLogin, aggregateVerifier: "torus-auth0-twitter-lrc", subVerifierDetails: [sub], network: .legacy(.TESTNET))
                        Task {
                            do {
                                let loginData = try await tdsdk.triggerLogin().torusKey.finalKeyData!
                                print(loginData)
                            } catch {
                                print("Error occured")
                            }
                        }
                    }, label: {
                        Text("Twitter Login")
                    })

                    Button(action: {
                        let sub = SubVerifierDetails(loginType: .web,
                                                     loginProvider: .github,
                                                     clientId: "PC2a4tfNRvXbT48t89J5am0oFM21Nxff",
                                                     verifier: "torus-auth0-github-lrc",
                                                     redirectURL: "tdsdk://tdsdk/oauthCallback",
                                                     browserRedirectURL: "https://scripts.toruswallet.io/redirect.html",
                                                     jwtParams: ["domain": "torus-test.auth0.com"])

                        let tdsdk = CustomAuth(web3AuthClientId: "PC2a4tfNRvXbT48t89J5am0oFM21Nxff", aggregateVerifierType: .singleLogin, aggregateVerifier: "torus-auth0-github-lrc", subVerifierDetails: [sub], network: .legacy(.TESTNET))
                        Task {
                            do {
                                let loginData = try await tdsdk.triggerLogin().torusKey.finalKeyData!
                                print(loginData)
                            } catch {
                                print("Error occured")
                            }
                        }
                    }, label: {
                        Text("Github Login")
                    })

                    Button(action: {
                        let sub = SubVerifierDetails(loginType: .web,
                                                     loginProvider: .linkedin,
                                                     clientId: "59YxSgx79Vl3Wi7tQUBqQTRTxWroTuoc",
                                                     verifier: "torus-auth0-linkedin-lrc",
                                                     redirectURL: "tdsdk://tdsdk/oauthCallback",
                                                     jwtParams: ["domain": "torus-test.auth0.com"])

                        let tdsdk = CustomAuth(web3AuthClientId: "59YxSgx79Vl3Wi7tQUBqQTRTxWroTuoc", aggregateVerifierType: .singleLogin, aggregateVerifier: "torus-auth0-linkedin-lrc", subVerifierDetails: [sub], network: .legacy(.TESTNET))
                        Task {
                            do {
                                let loginData = try await tdsdk.triggerLogin().torusKey.finalKeyData!
                                print(loginData)
                            } catch {
                                print("Error occured")
                            }
                        }
                    }, label: {
                        Text("Linkedin Login")
                    })

                    Button(action: {
                        let sub = SubVerifierDetails(loginType: .web,
                                                     loginProvider: .apple,
                                                     clientId: "m1Q0gvDfOyZsJCZ3cucSQEe9XMvl9d9L",
                                                     verifier: "torus-auth0-apple-lrc",
                                                     redirectURL: "tdsdk://tdsdk/oauthCallback",
                                                     jwtParams: ["domain": "torus-test.auth0.com"])

                        let tdsdk = CustomAuth(web3AuthClientId: "m1Q0gvDfOyZsJCZ3cucSQEe9XMvl9d9L", aggregateVerifierType: .singleLogin, aggregateVerifier: "torus-auth0-apple-lrc", subVerifierDetails: [sub], network: .legacy(.TESTNET))
                        Task {
                            do {
                                let loginData = try await tdsdk.triggerLogin().torusKey.finalKeyData!
                                print(loginData)
                            } catch {
                                print("Error occured")
                            }
                        }
                    }, label: {
                        Text("Apple Login")
                    })
                    // }

                    // Group {
                    Button(action: {
                        let sub = SubVerifierDetails(loginType: .web,
                                                     loginProvider: .jwt,
                                                     clientId: "P7PJuBCXIHP41lcyty0NEb7Lgf7Zme8Q",
                                                     verifier: "torus-auth0-email-passwordless",
                                                     redirectURL: "tdsdk://tdsdk/oauthCallback",
                                                     jwtParams: ["domain": "torus-test.auth0.com", "verifier_id_field": "name"])

                        let tdsdk = CustomAuth(web3AuthClientId: "P7PJuBCXIHP41lcyty0NEb7Lgf7Zme8Q", aggregateVerifierType: .singleLogin, aggregateVerifier: "torus-auth0-email-passwordless", subVerifierDetails: [sub], network: .legacy(.TESTNET))
                        Task {
                            do {
                                let loginData = try await tdsdk.triggerLogin().torusKey.finalKeyData!
                                print(loginData)
                            } catch {
                                print("Error occured")
                            }
                        }
                    }, label: {
                        Text("Email-password Login")
                    })

                    Button(action: {
                        let sub = SubVerifierDetails(loginType: .web,
                                                     loginProvider: .kakao,
                                                     clientId: "wpkcc7alGJjEgjaL6q5AWRqgRWHFsdTL",
                                                     verifier: "torus-auth0-kakao-lrc",
                                                     redirectURL: "tdsdk://tdsdk/oauthCallback",
                                                     jwtParams: ["domain": "torus-test.auth0.com"])

                        let tdsdk = CustomAuth(web3AuthClientId: "wpkcc7alGJjEgjaL6q5AWRqgRWHFsdTL", aggregateVerifierType: .singleLogin, aggregateVerifier: "torus-auth0-kakao-lrc", subVerifierDetails: [sub], network: .legacy(.TESTNET))
                        Task {
                            do {
                                let loginData = try await tdsdk.triggerLogin().torusKey.finalKeyData!
                                print(loginData)
                            } catch {
                                print("Error occured")
                            }
                        }
                    }, label: {
                        Text("Kakao Login")
                    })

                    Button(action: {
                        let sub = SubVerifierDetails(loginType: .web,
                                                     loginProvider: .apple,
                                                     clientId: "dhFGlWQMoACOI5oS5A1jFglp772OAWr1",
                                                     verifier: "torus-auth0-weibo-lrc",
                                                     redirectURL: "tdsdk://tdsdk/oauthCallback",
                                                     jwtParams: ["domain": "torus-test.auth0.com"])

                        let tdsdk = CustomAuth(web3AuthClientId: "dhFGlWQMoACOI5oS5A1jFglp772OAWr1", aggregateVerifierType: .singleLogin, aggregateVerifier: "torus-auth0-weibo-lrc", subVerifierDetails: [sub], network: .legacy(.TESTNET))
                        Task {
                            do {
                                let loginData = try await tdsdk.triggerLogin().torusKey.finalKeyData!
                                print(loginData)
                            } catch {
                                print("Error occured")
                            }
                        }
                    }, label: {
                        Text("Weibo Login")
                    })

                    Button(action: {
                        let sub = SubVerifierDetails(loginType: .web,
                                                     loginProvider: .wechat,
                                                     clientId: "cewDD3i6F1vtHeV1KIbaxUZ8vJQjJZ8V",
                                                     verifier: "torus-auth0-wechat-lrc",
                                                     redirectURL: "tdsdk://tdsdk/oauthCallback",
                                                     jwtParams: ["domain": "torus-test.auth0.com"])

                        let tdsdk = CustomAuth(web3AuthClientId: "cewDD3i6F1vtHeV1KIbaxUZ8vJQjJZ8V", aggregateVerifierType: .singleLogin, aggregateVerifier: "torus-auth0-wechat-lrc", subVerifierDetails: [sub], network: .legacy(.TESTNET))
                        Task {
                            do {
                                let loginData = try await tdsdk.triggerLogin().torusKey.finalKeyData!
                                print(loginData)
                            } catch {
                                print("Error occured")
                            }
                        }
                    }, label: {
                        Text("Wechat Login")
                    })
                }
                // }

                Section(header: Text("Single ID verifier")) {
                    Button(action: {
                        let sub = SubVerifierDetails(loginType: .installed,
                                                     loginProvider: .google,
                                                     clientId: "238941746713-vfap8uumijal4ump28p9jd3lbe6onqt4.apps.googleusercontent.com",
                                                     verifier: "google-ios",
                                                     redirectURL: "com.googleusercontent.apps.238941746713-vfap8uumijal4ump28p9jd3lbe6onqt4:/oauthredirect")
                        let tdsdk = CustomAuth(web3AuthClientId: "238941746713-vfap8uumijal4ump28p9jd3lbe6onqt4.apps.googleusercontent.com", aggregateVerifierType: .singleIdVerifier, aggregateVerifier: "multigoogle-torus", subVerifierDetails: [sub], network: .legacy(.TESTNET))
                        Task {
                            do {
                                let loginData = try await tdsdk.triggerLogin().torusKey.finalKeyData!
                                print(loginData)
                            } catch {
                                print("Error occured")
                            }
                        }
                    }, label: {
                        Text("Google Login - Deep link flow")
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
