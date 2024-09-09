import CustomAuth
import SwiftUI

struct ContentView: View {
    
    var body: some View {
        VStack {
            Button(action: {
                Task {
                    do {
                        let sub = SingleLoginParams(typeOfLogin: .google, verifier: "w3a-google-demo", clientId: "519228911939-cri01h55lsjbsia1k7ll6qpalrus75ps.apps.googleusercontent.com", redirectURL: "https://scripts.toruswallet.io/redirect.html")
                        
                        let customAuthArgs = CustomAuthArgs(urlScheme: "tdsdk://tdsdk/oauthCallback", network: .sapphire(.SAPPHIRE_MAINNET), enableOneKey: true, web3AuthClientId: "BPi5PB_UiIZ-cPz1GtV5i1I2iOSOHuimiXBI0e-Oe_u6X3oVAbCiAZOTEBtTXw4tsluTITPqA8zMsfxIKMjiqNQ")
                        let customAuth = try CustomAuth(config: customAuthArgs)
                        let torusLoginResponse = try await customAuth.triggerLogin(args: sub)
                        let encoded = try JSONEncoder().encode(torusLoginResponse)
                        print(String(data: encoded, encoding: .utf8)!)
                    } catch {
                        print(error)
                    }
                    
                }
            }, label: {
                Text("Google Login")
            })
            
            Button(action: {
                Task {
                    do {
                        let sub = SingleLoginParams(typeOfLogin: .discord, verifier: "w3a-discord-demo", clientId: "1151006428610433095", redirectURL: "https://scripts.toruswallet.io/redirect.html")
                        
                        let customAuthArgs = CustomAuthArgs(urlScheme: "tdsdk://tdsdk/oauthCallback", network: .sapphire(.SAPPHIRE_MAINNET), enableOneKey: true, web3AuthClientId: "BPi5PB_UiIZ-cPz1GtV5i1I2iOSOHuimiXBI0e-Oe_u6X3oVAbCiAZOTEBtTXw4tsluTITPqA8zMsfxIKMjiqNQ")
                        
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
            
            
             Button(action: {
                 Task {
                     do {
                         let sub = SingleLoginParams(typeOfLogin: .facebook, verifier: "w3a-facebook-demo", clientId: "342380202252650", redirectURL: "https://scripts.toruswallet.io/redirect.html")
                         
                         let customAuthArgs = CustomAuthArgs(urlScheme: "tdsdk://tdsdk/oauthCallback", network: .sapphire(.SAPPHIRE_MAINNET), enableOneKey: true, web3AuthClientId: "BPi5PB_UiIZ-cPz1GtV5i1I2iOSOHuimiXBI0e-Oe_u6X3oVAbCiAZOTEBtTXw4tsluTITPqA8zMsfxIKMjiqNQ")
                         
                         let customAuth = try CustomAuth(config: customAuthArgs)
                         let torusLoginResponse = try await customAuth.triggerLogin(args: sub)
                         let encoded = try JSONEncoder().encode(torusLoginResponse)
                         print(String(data: encoded, encoding: .utf8)!)
                     } catch {
                         print(error)
                     }
                 }
             }, label: {
             Text("Facebook Login")
             })
            
            Button(action: {
                let sub = SingleLoginParams(typeOfLogin: .twitch, verifier: "w3a-twitch-demo", clientId: "3k7e70gowvxjaxg71hjnc8h8ih3bpf", redirectURL: "https://scripts.toruswallet.io/redirect.html")
                let customAuthArgs = CustomAuthArgs(urlScheme: "tdsdk://tdsdk/oauthCallback", network: .sapphire(.SAPPHIRE_MAINNET), enableOneKey: true, web3AuthClientId: "BPi5PB_UiIZ-cPz1GtV5i1I2iOSOHuimiXBI0e-Oe_u6X3oVAbCiAZOTEBtTXw4tsluTITPqA8zMsfxIKMjiqNQ")
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
            
            Button(action: {
                let sub = SingleLoginParams(typeOfLogin: .apple, verifier: "w3a-auth0-demo", clientId: "hUVVf4SEsZT7syOiL0gLU9hFEtm2gQ6O", redirectURL: "https://scripts.toruswallet.io/redirect.html", jwtParams: Auth0ClientOptions(connection: "apple", domain: "web3auth.au.auth0.com"))
                let customAuthArgs = CustomAuthArgs(urlScheme: "tdsdk://tdsdk/oauthCallback", network: .sapphire(.SAPPHIRE_MAINNET), enableOneKey: true, web3AuthClientId: "BPi5PB_UiIZ-cPz1GtV5i1I2iOSOHuimiXBI0e-Oe_u6X3oVAbCiAZOTEBtTXw4tsluTITPqA8zMsfxIKMjiqNQ")
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
                Text("Apple Login")
            })
            
            Button(action: {
                let sub = SingleLoginParams(typeOfLogin: .github, verifier: "w3a-auth0-demo", clientId: "hUVVf4SEsZT7syOiL0gLU9hFEtm2gQ6O", redirectURL: "https://scripts.toruswallet.io/redirect.html", jwtParams: Auth0ClientOptions(connection: "github", domain: "web3auth.au.auth0.com", verifierIdField: "sub"))
                let customAuthArgs = CustomAuthArgs(urlScheme: "tdsdk://tdsdk/oauthCallback", network: .sapphire(.SAPPHIRE_MAINNET), enableOneKey: true, web3AuthClientId: "BPi5PB_UiIZ-cPz1GtV5i1I2iOSOHuimiXBI0e-Oe_u6X3oVAbCiAZOTEBtTXw4tsluTITPqA8zMsfxIKMjiqNQ")
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
                Text("JWT Login")
            })
            
            Button(action: {
                let sub = SingleLoginParams(typeOfLogin: .email_password,
                                             verifier: "torus-auth0-email-password", clientId: "sqKRBVSdwa4WLkaq419U7Bamlh5vK1H7",
                                             redirectURL: "tdsdk://tdsdk/oauthCallback", jwtParams: Auth0ClientOptions(
                                                connection: "Username-Password-Authentication",
                                                domain: "torus-test.auth0.com",
                                                    verifierIdField: "name"))
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
                Text("Email Password")
            })
            
            Label(
                title: { Text("Aggregate Verifiers") },
                icon: { Image(systemName: "circle") }
            )
            
            Button(action: {
                let aggregateLoginParams = AggregateLoginParams(aggregateVerifierType: AggregateVerifierType.single_id_verifier, verifierIdentifier: "aggregate-sapphire", subVerifierDetailsArray: [SingleLoginParams(typeOfLogin: .google, verifier: "w3a-google", clientId: "519228911939-cri01h55lsjbsia1k7ll6qpalrus75ps.apps.googleusercontent.com", redirectURL: "https://scripts.toruswallet.io/redirect.html")])
                
                let customAuthArgs = CustomAuthArgs(urlScheme: "tdsdk://tdsdk/oauthCallback", network: .sapphire(.SAPPHIRE_MAINNET), enableOneKey: true, web3AuthClientId: "BPi5PB_UiIZ-cPz1GtV5i1I2iOSOHuimiXBI0e-Oe_u6X3oVAbCiAZOTEBtTXw4tsluTITPqA8zMsfxIKMjiqNQ")
                Task {
                    do {
                        let customAuth = try CustomAuth(config: customAuthArgs)
                        let torusLoginResponse = try await customAuth.triggerAggregateLogin(args: aggregateLoginParams)
                        let encoded = try JSONEncoder().encode(torusLoginResponse)
                        print(String(data: encoded, encoding: .utf8)!)
                    } catch {
                        print(error)
                    }
                }
            }, label: {
                Text("Aggregate Gmail")
            })
            
            Button(action: {
                let subVerifierDetailsArray = SingleLoginParams(typeOfLogin: .email_passwordless, verifier: "w3a-a0-email-passwordless", clientId: "QiEf8qZ9IoasbZsbHvjKZku4LdnRC1Ct", redirectURL: "https://scripts.toruswallet.io/redirect.html", jwtParams: Auth0ClientOptions(domain: "web3auth.au.auth0.com", verifierIdField: "email"))
                let aggregateLoginParams = AggregateLoginParams(aggregateVerifierType: AggregateVerifierType.single_id_verifier, verifierIdentifier: "aggregate-sapphire", subVerifierDetailsArray: [subVerifierDetailsArray])
                
                let customAuthArgs = CustomAuthArgs(urlScheme: "tdsdk://tdsdk/oauthCallback", network: .sapphire(.SAPPHIRE_MAINNET), enableOneKey: true, web3AuthClientId: "BPi5PB_UiIZ-cPz1GtV5i1I2iOSOHuimiXBI0e-Oe_u6X3oVAbCiAZOTEBtTXw4tsluTITPqA8zMsfxIKMjiqNQ")
                Task {
                    do {
                        let customAuth = try CustomAuth(config: customAuthArgs)
                        let torusLoginResponse = try await customAuth.triggerAggregateLogin(args: aggregateLoginParams)
                        let encoded = try JSONEncoder().encode(torusLoginResponse)
                        print(String(data: encoded, encoding: .utf8)!)
                    } catch {
                        print(error)
                    }
                }
            }, label: {
                Text("Aggregate Email Passwordless")
            })
            
        }
    }
}
