import CustomAuth
import Foundation

struct User {
    var publicAddress: String
    var privateKey: String
    var userInfo: UserInfo
}

class ViewModel: ObservableObject {
    @Published var user: User?
    @Published var showingAlert: Bool = false
    private var testnetNetworkUrl: String = "https://rpc.ankr.com/eth_ropsten"

    func removeUser() {
        user = nil
    }
}

extension ViewModel {
    func googleLogin() {
        Task {
            do {
                let sub = SingleLoginParams(typeOfLogin: .google, verifier: "w3a-google-demo", clientId: "519228911939-cri01h55lsjbsia1k7ll6qpalrus75ps.apps.googleusercontent.com")

                let customAuthArgs = CustomAuthArgs(urlScheme: "tdsdk://tdsdk/oauthCallback", network: .sapphire(.SAPPHIRE_MAINNET), enableOneKey: true, web3AuthClientId: "BPi5PB_UiIZ-cPz1GtV5i1I2iOSOHuimiXBI0e-Oe_u6X3oVAbCiAZOTEBtTXw4tsluTITPqA8zMsfxIKMjiqNQ")
                let customAuth = try CustomAuth(config: customAuthArgs)
                let torusLoginResponse = try await customAuth.triggerLogin(args: sub)

                DispatchQueue.main.async {
                    self.user = User(publicAddress: torusLoginResponse.torusKey.finalKeyData.evmAddress, privateKey: torusLoginResponse.torusKey.finalKeyData.privKey, userInfo: torusLoginResponse.singleVerifierResponse.userInfo)
                }
            } catch {
                print(error)
            }
        }
    }

    func discordLogin() {
        Task {
            do {
                let sub = SingleLoginParams(typeOfLogin: .discord, verifier: "w3a-discord-demo", clientId: "1151006428610433095")

                let customAuthArgs = CustomAuthArgs(urlScheme: "tdsdk://tdsdk/oauthCallback", network: .sapphire(.SAPPHIRE_MAINNET), enableOneKey: true, web3AuthClientId: "BPi5PB_UiIZ-cPz1GtV5i1I2iOSOHuimiXBI0e-Oe_u6X3oVAbCiAZOTEBtTXw4tsluTITPqA8zMsfxIKMjiqNQ")

                let customAuth = try CustomAuth(config: customAuthArgs)
                let torusLoginResponse = try await customAuth.triggerLogin(args: sub)

                DispatchQueue.main.async {
                    self.user = User(publicAddress: torusLoginResponse.torusKey.finalKeyData.evmAddress, privateKey: torusLoginResponse.torusKey.finalKeyData.privKey, userInfo: torusLoginResponse.singleVerifierResponse.userInfo)
                }
            } catch {
                print(error)
            }
        }
    }

    func facebookLogin() {
        Task {
            do {
                let sub = SingleLoginParams(typeOfLogin: .facebook, verifier: "w3a-facebook-demo", clientId: "342380202252650")

                let customAuthArgs = CustomAuthArgs(urlScheme: "tdsdk://tdsdk/oauthCallback", network: .sapphire(.SAPPHIRE_MAINNET), enableOneKey: true, web3AuthClientId: "BPi5PB_UiIZ-cPz1GtV5i1I2iOSOHuimiXBI0e-Oe_u6X3oVAbCiAZOTEBtTXw4tsluTITPqA8zMsfxIKMjiqNQ")

                let customAuth = try CustomAuth(config: customAuthArgs)
                let torusLoginResponse = try await customAuth.triggerLogin(args: sub)
                DispatchQueue.main.async {
                    self.user = User(publicAddress: torusLoginResponse.torusKey.finalKeyData.evmAddress, privateKey: torusLoginResponse.torusKey.finalKeyData.privKey, userInfo: torusLoginResponse.singleVerifierResponse.userInfo)
                }
            } catch {
                print(error)
            }
        }
    }

    func twitchLogin() {
        Task {
            do {
                let sub = SingleLoginParams(typeOfLogin: .twitch, verifier: "w3a-twitch-demo", clientId: "3k7e70gowvxjaxg71hjnc8h8ih3bpf")
                let customAuthArgs = CustomAuthArgs(urlScheme: "tdsdk://tdsdk/oauthCallback", network: .sapphire(.SAPPHIRE_MAINNET), enableOneKey: true, web3AuthClientId: "BPi5PB_UiIZ-cPz1GtV5i1I2iOSOHuimiXBI0e-Oe_u6X3oVAbCiAZOTEBtTXw4tsluTITPqA8zMsfxIKMjiqNQ")
                let customAuth = try CustomAuth(config: customAuthArgs)
                let torusLoginResponse = try await customAuth.triggerLogin(args: sub)
                DispatchQueue.main.async {
                    self.user = User(publicAddress: torusLoginResponse.torusKey.finalKeyData.evmAddress, privateKey: torusLoginResponse.torusKey.finalKeyData.privKey, userInfo: torusLoginResponse.singleVerifierResponse.userInfo)
                }
            } catch {
                print(error)
            }
        }
    }

    func githubLogin() {
        Task {
            do {
                let sub = SingleLoginParams(typeOfLogin: .github, verifier: "w3a-auth0-demo", clientId: "hUVVf4SEsZT7syOiL0gLU9hFEtm2gQ6O", jwtParams: Auth0ClientOptions(connection: "github", domain: "web3auth.au.auth0.com", verifierIdField: "sub"))
                let customAuthArgs = CustomAuthArgs(urlScheme: "tdsdk://tdsdk/oauthCallback", network: .sapphire(.SAPPHIRE_MAINNET), enableOneKey: true, web3AuthClientId: "BPi5PB_UiIZ-cPz1GtV5i1I2iOSOHuimiXBI0e-Oe_u6X3oVAbCiAZOTEBtTXw4tsluTITPqA8zMsfxIKMjiqNQ")
                let customAuth = try CustomAuth(config: customAuthArgs)
                let torusLoginResponse = try await customAuth.triggerLogin(args: sub)
                DispatchQueue.main.async {
                    self.user = User(publicAddress: torusLoginResponse.torusKey.finalKeyData.evmAddress, privateKey: torusLoginResponse.torusKey.finalKeyData.privKey, userInfo: torusLoginResponse.singleVerifierResponse.userInfo)
                }
            } catch {
                print(error)
            }
        }
    }

    func appleLogin() {
        Task {
            do {
                let sub = SingleLoginParams(typeOfLogin: .apple, verifier: "w3a-auth0-demo", clientId: "hUVVf4SEsZT7syOiL0gLU9hFEtm2gQ6O", jwtParams: Auth0ClientOptions(connection: "apple", domain: "web3auth.au.auth0.com"))
                let customAuthArgs = CustomAuthArgs(urlScheme: "tdsdk://tdsdk/oauthCallback", network: .sapphire(.SAPPHIRE_MAINNET), enableOneKey: true, web3AuthClientId: "BPi5PB_UiIZ-cPz1GtV5i1I2iOSOHuimiXBI0e-Oe_u6X3oVAbCiAZOTEBtTXw4tsluTITPqA8zMsfxIKMjiqNQ")

                let customAuth = try CustomAuth(config: customAuthArgs)
                let torusLoginResponse = try await customAuth.triggerLogin(args: sub)

                DispatchQueue.main.async {
                    self.user = User(publicAddress: torusLoginResponse.torusKey.finalKeyData.evmAddress, privateKey: torusLoginResponse.torusKey.finalKeyData.privKey, userInfo: torusLoginResponse.singleVerifierResponse.userInfo)
                }
            } catch {
                print(error)
            }
        }
    }

    func emailPasswordLogin() {
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
                DispatchQueue.main.async {
                    self.user = User(publicAddress: torusLoginResponse.torusKey.finalKeyData.evmAddress, privateKey: torusLoginResponse.torusKey.finalKeyData.privKey, userInfo: torusLoginResponse.singleVerifierResponse.userInfo)
                }
            } catch {
                print(error)
            }
        }
    }
}
