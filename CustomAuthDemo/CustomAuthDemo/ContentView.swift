import CustomAuth
import SwiftUI

struct ContentView: View {
    @State private var inputDetail: String = ""
    
    var body: some View {
        VStack {
            Button(action: {
                Task {
                    do {
                        let sub = SingleLoginParams(typeOfLogin: .google, verifier: "w3a-google-demo", clientId: "519228911939-cri01h55lsjbsia1k7ll6qpalrus75ps.apps.googleusercontent.com")

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
                        let sub = SingleLoginParams(typeOfLogin: .discord, verifier: "w3a-discord-demo", clientId: "1151006428610433095")

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
                        let sub = SingleLoginParams(typeOfLogin: .facebook, verifier: "w3a-facebook-demo", clientId: "342380202252650")

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
                Task {
                    do {
                        let sub = SingleLoginParams(typeOfLogin: .twitch, verifier: "w3a-twitch-demo", clientId: "3k7e70gowvxjaxg71hjnc8h8ih3bpf")
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
                Text("Twitch Login")
            })

            Button(action: {
                Task {
                    do {
                        let sub = SingleLoginParams(typeOfLogin: .apple, verifier: "w3a-auth0-demo", clientId: "hUVVf4SEsZT7syOiL0gLU9hFEtm2gQ6O", jwtParams: Auth0ClientOptions(connection: "apple", domain: "web3auth.au.auth0.com"))
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
                Text("Apple Login")
            })

            Button(action: {
                Task {
                    do {
                        let sub = SingleLoginParams(typeOfLogin: .github, verifier: "w3a-auth0-demo", clientId: "hUVVf4SEsZT7syOiL0gLU9hFEtm2gQ6O", jwtParams: Auth0ClientOptions(connection: "github", domain: "web3auth.au.auth0.com", verifierIdField: "sub"))
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
                Text("GitHub Login")
            })

            Button(action: {
                Task {
                    do {
                        let sub = SingleLoginParams(typeOfLogin: .email_password,
                                                    verifier: "torus-auth0-email-password", clientId: "sqKRBVSdwa4WLkaq419U7Bamlh5vK1H7",
                                                    jwtParams: Auth0ClientOptions(
                                                        connection: "Username-Password-Authentication",
                                                        domain: "torus-test.auth0.com",
                                                        verifierIdField: "name"))
                        let customAuthArgs = CustomAuthArgs(urlScheme: "tdsdk://tdsdk/oauthCallback", network: .legacy(.TESTNET), enableOneKey: true, web3AuthClientId: "BPi5PB_UiIZ-cPz1GtV5i1I2iOSOHuimiXBI0e-Oe_u6X3oVAbCiAZOTEBtTXw4tsluTITPqA8zMsfxIKMjiqNQ")
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
                title: { Text("Hosted Passwordless") },
                icon: { Image(systemName: "circle") }
            )
            TextField(
                "Email or Phone Number",
                text: $inputDetail
            )
            .disableAutocorrection(true)
            .border(.secondary)
            
            Button(action: {
                Task {
                    do {
                        let sub = SingleLoginParams(typeOfLogin: .email_passwordless,
                                                    verifier: "torus-auth0-email-passwordless-lrc", clientId: "P7PJuBCXIHP41lcyty0NEb7Lgf7Zme8Q",
                                                    jwtParams: Auth0ClientOptions(verifierIdField: "name", login_hint: inputDetail, flow_type: .link))
                        let customAuthArgs = CustomAuthArgs(urlScheme: "tdsdk://tdsdk/oauthCallback", network: .legacy(.TESTNET), enableOneKey: true, web3AuthClientId: "BPi5PB_UiIZ-cPz1GtV5i1I2iOSOHuimiXBI0e-Oe_u6X3oVAbCiAZOTEBtTXw4tsluTITPqA8zMsfxIKMjiqNQ")
                        let customAuth = try CustomAuth(config: customAuthArgs)
                        let torusLoginResponse = try await customAuth.triggerLogin(args: sub)
                        let encoded = try JSONEncoder().encode(torusLoginResponse)
                        print(String(data: encoded, encoding: .utf8)!)
                    } catch {
                        print(error)
                    }
                }
            }, label: {
                Text("Email Passwordless")
            })
            
            
            Button(action: {
                Task {
                    do {
                        let sub = SingleLoginParams(typeOfLogin: .sms_passwordless,
                                                    verifier: "torus-sms-passwordless-lrc", clientId: "P7PJuBCXIHP41lcyty0NEb7Lgf7Zme8Q",
                                                    jwtParams: Auth0ClientOptions(login_hint: inputDetail, flow_type: .code))
                        let customAuthArgs = CustomAuthArgs(urlScheme: "tdsdk://tdsdk/oauthCallback", network: .legacy(.TESTNET), enableOneKey: true, web3AuthClientId: "BPi5PB_UiIZ-cPz1GtV5i1I2iOSOHuimiXBI0e-Oe_u6X3oVAbCiAZOTEBtTXw4tsluTITPqA8zMsfxIKMjiqNQ")
                        let customAuth = try CustomAuth(config: customAuthArgs)
                        let torusLoginResponse = try await customAuth.triggerLogin(args: sub)
                        let encoded = try JSONEncoder().encode(torusLoginResponse)
                        print(String(data: encoded, encoding: .utf8)!)
                    } catch {
                        print(error)
                    }
                }
            }, label: {
                Text("SMS Passwordless")
            })

            Label(
                title: { Text("Aggregate Verifiers") },
                icon: { Image(systemName: "circle") }
            )

            Button(action: {
                Task {
                    do {
                        let aggregateLoginParams = AggregateLoginParams(aggregateVerifierType: AggregateVerifierType.single_id_verifier, verifierIdentifier: "aggregate-sapphire", subVerifierDetailsArray: [SingleLoginParams(typeOfLogin: .google, verifier: "w3a-google", clientId: "519228911939-cri01h55lsjbsia1k7ll6qpalrus75ps.apps.googleusercontent.com")])

                        let customAuthArgs = CustomAuthArgs(urlScheme: "tdsdk://tdsdk/oauthCallback", network: .sapphire(.SAPPHIRE_MAINNET), enableOneKey: true, web3AuthClientId: "BPi5PB_UiIZ-cPz1GtV5i1I2iOSOHuimiXBI0e-Oe_u6X3oVAbCiAZOTEBtTXw4tsluTITPqA8zMsfxIKMjiqNQ")
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
                Task {
                    do {
                        let subVerifierDetailsArray = SingleLoginParams(typeOfLogin: .github, verifier: "w3a-a0-github", clientId: "hiLqaop0amgzCC0AXo4w0rrG9abuJTdu", jwtParams: OAuthClientOptions(domain: "web3auth.au.auth0.com", verifierIdField: "email"))
                        let aggregateLoginParams = AggregateLoginParams(aggregateVerifierType: AggregateVerifierType.single_id_verifier, verifierIdentifier: "aggregate-sapphire", subVerifierDetailsArray: [subVerifierDetailsArray])

                        let customAuthArgs = CustomAuthArgs(urlScheme: "tdsdk://tdsdk/oauthCallback", network: .sapphire(.SAPPHIRE_MAINNET), enableOneKey: true, web3AuthClientId: "BPi5PB_UiIZ-cPz1GtV5i1I2iOSOHuimiXBI0e-Oe_u6X3oVAbCiAZOTEBtTXw4tsluTITPqA8zMsfxIKMjiqNQ")
                        let customAuth = try CustomAuth(config: customAuthArgs)
                        let torusLoginResponse = try await customAuth.triggerAggregateLogin(args: aggregateLoginParams)
                        let encoded = try JSONEncoder().encode(torusLoginResponse)
                        print(String(data: encoded, encoding: .utf8)!)
                    } catch {
                        print(error)
                    }
                }
            }, label: {
                Text("Aggregate GitHub")
            })
        }
    }
}
