import CustomAuth
import SwiftUI

struct ContentView: View {
    
    var body: some View {
        VStack {
            Button(action: {
                Task {
                    do {
                        let sub = SingleLoginParams(typeOfLogin: .google, verifier: "google-lrc", clientId: "221898609709-obfn3p63741l5333093430j3qeiinaa8.apps.googleusercontent.com", redirectURL: "https://scripts.toruswallet.io/redirect.html")

                        let customAuthArgs = CustomAuthArgs(urlScheme: "tdsdk://tdsdk/oauthCallback", network: .sapphire(.SAPPHIRE_DEVNET), enableOneKey: true, web3AuthClientId: "BAh0_c0G8U8GoMUIYDcX_f65fU_N9O0mWz6xM6RqBfaaAlYsTha8oOef7ifXPjd_bCTJdfWQemmrbY6KepC7XNA")

                        let customAuth = try CustomAuth(config: customAuthArgs)
                        let torusLoginResponse = try await customAuth.triggerLogin(args: sub)
                        let encoded = try JSONEncoder().encode(torusLoginResponse)
                        debugPrint(String(data: encoded, encoding: .utf8)!)
                    } catch {
                        debugPrint(error)
                    }

                }
            }, label: {
                Text("Google Login")
            })

            Button(action: {
                Task {
                    do {
                        let sub = SingleLoginParams(typeOfLogin: .discord, verifier: "dhruv-discord", clientId: "1034724991972954172", redirectURL: "https://scripts.toruswallet.io/redirect.html")

                        let customAuthArgs = CustomAuthArgs(urlScheme: "tdsdk://tdsdk/oauthCallback", network: .legacy(.TESTNET), enableOneKey: true, web3AuthClientId: "BHgArYmWwSeq21czpcarYh0EVq2WWOzflX-NTK-tY1-1pauPzHKRRLgpABkmYiIV_og9jAvoIxQ8L3Smrwe04Lw")

                        let customAuth = try CustomAuth(config: customAuthArgs)
                        let torusLoginResponse = try await customAuth.triggerLogin(args: sub)
                        let encoded = try JSONEncoder().encode(torusLoginResponse)
                        print(String(data: encoded, encoding: .utf8)!)
                    } catch {
                        print(error)
                    }

                }
            }, label: {
                Text("Discord Login")
            })
            /*
            Button(action: {
                Task {
                    do {
                        let sub = SingleLoginParams(typeOfLogin: .facebook,                                  verifier: "facebook-shubs",
                            clientId: "659561074900150",
                            redirectURL: "https://scripts.toruswallet.io/redirect.html")

                        let customAuthArgs = CustomAuthArgs(urlScheme: "tdsdk://tdsdk/oauthCallback", network: .sapphire(.SAPPHIRE_MAINNET), enableOneKey: true, web3AuthClientId: "BPi5PB_UiIZ-cPz1GtV5i1I2iOSOHuimiXBI0e-Oe_u6X3oVAbCiAZOTEBtTXw4tsluTITPqA8zMsfxIKMjiqNQ")

                        let customAuth = try CustomAuth(config: customAuthArgs)
                        let torusLoginResponse = try await customAuth.triggerLogin(args: sub)
                        let encoded = try JSONEncoder().encode(torusLoginResponse)
                        debugPrint(String(data: encoded, encoding: .utf8)!)
                    } catch {
                        debugPrint(error)
                    }

                }
            }, label: {
                Text("Facebook Login")
            })
            */
            
            Button(action: {
                let sub = SubVerifierDetails(typeOfLogin: .reddit,
                                             verifier: "reddit-shubs", clientId: "rXIp6g2y3h1wqg",
                                             redirectURL: "tdsdk://tdsdk/oauthCallback")
                let customAuthArgs = CustomAuthArgs(urlScheme: "tdsdk://tdsdk/oauthCallback", network: .legacy(.TESTNET), enableOneKey: true, web3AuthClientId: "BPi5PB_UiIZ-cPz1GtV5i1I2iOSOHuimiXBI0e-Oe_u6X3oVAbCiAZOTEBtTXw4tsluTITPqA8zMsfxIKMjiqNQ")
                Task {
                    do {
                        let customAuth = try CustomAuth(config: customAuthArgs)
                        let torusLoginResponse = try await customAuth.triggerLogin(args: sub)
                        let encoded = try JSONEncoder().encode(torusLoginResponse)
                        print(String(data: encoded, encoding: .utf8)!)
                    } catch {
                        print(error)
                    }
                }
            }, label: {
                Text("Reddit Login")
            })
            
            Button(action: {
                let sub = SubVerifierDetails(typeOfLogin: .twitch,
                                             verifier: "twitch-shubs", clientId: "p560duf74b2bidzqu6uo0b3ot7qaao",
                                             redirectURL: "tdsdk://tdsdk/oauthCallback")
                let customAuthArgs = CustomAuthArgs(urlScheme: "tdsdk://tdsdk/oauthCallback", network: .legacy(.TESTNET), enableOneKey: true, web3AuthClientId: "BPi5PB_UiIZ-cPz1GtV5i1I2iOSOHuimiXBI0e-Oe_u6X3oVAbCiAZOTEBtTXw4tsluTITPqA8zMsfxIKMjiqNQ")
                Task {
                    do {
                        let customAuth = try CustomAuth(config: customAuthArgs)
                        let torusLoginResponse = try await customAuth.triggerLogin(args: sub)
                        let encoded = try JSONEncoder().encode(torusLoginResponse)
                        print(String(data: encoded, encoding: .utf8)!)
                    } catch {
                        print(error)
                    }
                }
            }, label: {
                Text("Twitch Login")
            })
            
            /*
             let sub = SubVerifierDetails(loginType: .web,
                                          loginProvider: .facebook,
                                          clientId: "659561074900150",
                                          verifier: "facebook-shubs",
                                          redirectURL: "tdsdk://tdsdk/oauthCallback",
                                          browserRedirectURL: "https://scripts.toruswallet.io/redirect.html",
                                          urlSession: URLSession.shared)
             */
 /*
            Button(action: {
                Task {
                    do {
                        let sub = SingleLoginParams(typeOfLogin: .apple, verifier: "torus-auth0-apple-lrc", clientId: "m1Q0gvDfOyZsJCZ3cucSQEe9XMvl9d9L", redirectURL: "tdsdk://tdsdk/oauthCallback", jwtParams: Auth0ClientOptions(display: nil, prompt: nil, max_age: nil, ui_locales: nil, id_token_hint: nil, arc_values: nil, scope: nil, audience: nil, connection: "apple", domain: "torus-test.auth0.com", client_id: nil, redirect_url: nil, leeway: nil, verifierIdField: nil, isVerifierIdCaseSensitive: true, id_token: nil, access_token: nil, user_info_route: nil))

                        let customAuthArgs = CustomAuthArgs(urlScheme: "tdsdk://tdsdk/oauthCallback", network: .sapphire(.SAPPHIRE_DEVNET), enableOneKey: true, web3AuthClientId: "BAh0_c0G8U8GoMUIYDcX_f65fU_N9O0mWz6xM6RqBfaaAlYsTha8oOef7ifXPjd_bCTJdfWQemmrbY6KepC7XNA")

                        let customAuth = try CustomAuth(config: customAuthArgs)
                        let torusLoginResponse = try await customAuth.triggerLogin(args: sub)
                        let encoded = try JSONEncoder().encode(torusLoginResponse)
                        debugPrint(String(data: encoded, encoding: .utf8)!)
                    } catch {
                        debugPrint(error)
                    }

                }
            }, label: {
                Text("Apple Login")
            })
  */
        }
    }
}

// TODO: Update with all different combinations
/*
 struct ContentView: View {

     var body: some View {
         NavigationView {
             List {
                 Section(header: Text("Single Logins")) {
                     Button(action: {
                         let sub = SingleLoginParams(typeOfLogin: .google, verifier: "google-lrc", clientId: "221898609709-obfn3p63741l5333093430j3qeiinaa8.apps.googleusercontent.com", redirectURL: "tdsdk://tdsdk/oauthCallback")

                         let customAuthArgs = CustomAuthArgs(network: .sapphire(.SAPPHIRE_DEVNET), enableOneKey: true, web3AuthClientId: "BAh0_c0G8U8GoMUIYDcX_f65fU_N9O0mWz6xM6RqBfaaAlYsTha8oOef7ifXPjd_bCTJdfWQemmrbY6KepC7XNA")

                         let customAuth = CustomAuth(config: customAuthArgs)

                         Task {
                             do {
                                 let torusLoginResponse = try await customAuth.triggerLogin(args: sub)
                                 let encoded = JSONEncoder().encode(torusLoginResponse)
                                 debugPrint(encoded)
                             } catch {
                                 debugPrint(error)
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
 */
