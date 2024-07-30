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
    func googlePolygonLogin() {
        let sub = SubVerifierDetails(typeOfLogin: .google, verifier: "polygon-ios-test", clientId: "908137525998-fs00a3go5r7fpbntmui4lb8nhuqqtmaa.apps.googleusercontent.com", redirectURL: "https://scripts.toruswallet.io/redirect.html")

        let options = CustomAuthArgs(urlScheme: "torus://org.torusresearch.sample/redirect", network: .legacy(.CYAN), enableOneKey: true, web3AuthClientId: "CLIENT ID")

        Task {
            do {
                let customAuth = try CustomAuth(config: options)

                let keyDetails = try await customAuth.triggerLogin(args: sub)

                user = User(publicAddress: keyDetails.torusKey.finalKeyData.evmAddress, privateKey: keyDetails.torusKey.finalKeyData.privKey, userInfo: keyDetails.singleVerifierResponse.userInfo)
            } catch {
                print(error)
            }
        }
    }

    func googleLogin() {
        let sub = SubVerifierDetails(typeOfLogin: .google, verifier: "google-lrc", clientId: "221898609709-obfn3p63741l5333093430j3qeiinaa8.apps.googleusercontent.com", redirectURL: "https://scripts.toruswallet.io/redirect.html")

        let options = CustomAuthArgs(urlScheme: "tdsdk://tdsdk/oauthCallback", network: .legacy(.TESTNET), enableOneKey: true, web3AuthClientId: "CLIENT ID")

        Task {
            do {
                let customAuth = try CustomAuth(config: options)

                let keyDetails = try await customAuth.triggerLogin(args: sub)

                user = User(publicAddress: keyDetails.torusKey.finalKeyData.evmAddress, privateKey: keyDetails.torusKey.finalKeyData.privKey, userInfo: keyDetails.singleVerifierResponse.userInfo)
            } catch {
                print(error)
            }
        }
    }

    func redditLogin() {
        let sub = SubVerifierDetails(typeOfLogin: .reddit, verifier: "reddit-shubs", clientId: "rXIp6g2y3h1wqg", redirectURL: "https://scripts.toruswallet.io/redirect.html")

        let options = CustomAuthArgs(urlScheme: "tdsdk://tdsdk/oauthCallback", network: .legacy(.TESTNET), enableOneKey: true, web3AuthClientId: "CLIENT ID")

        Task {
            do {
                let customAuth = try CustomAuth(config: options)

                let keyDetails = try await customAuth.triggerLogin(args: sub)

                user = User(publicAddress: keyDetails.torusKey.finalKeyData.evmAddress, privateKey: keyDetails.torusKey.finalKeyData.privKey, userInfo: keyDetails.singleVerifierResponse.userInfo)
            } catch {
                print(error)
            }
        }
    }

    func discordLogin() {
        let sub = SubVerifierDetails(typeOfLogin: .discord, verifier: "dhruv-discord", clientId: "1034724991972954172", redirectURL: "https://scripts.toruswallet.io/redirect.html")

        let options = CustomAuthArgs(urlScheme: "tdsdk://tdsdk/oauthCallback", network: .legacy(.TESTNET), enableOneKey: true, web3AuthClientId: "CLIENT ID")

        Task {
            do {
                let customAuth = try CustomAuth(config: options)

                let keyDetails = try await customAuth.triggerLogin(args: sub)

                user = User(publicAddress: keyDetails.torusKey.finalKeyData.evmAddress, privateKey: keyDetails.torusKey.finalKeyData.privKey, userInfo: keyDetails.singleVerifierResponse.userInfo)
            } catch {
                print(error)
            }
        }
    }

    func facebookLogin() {
        let sub = SubVerifierDetails(typeOfLogin: .facebook, verifier: "facebook-shubs", clientId: "659561074900150", redirectURL: "https://scripts.toruswallet.io/redirect.html")

        let options = CustomAuthArgs(urlScheme: "tdsdk://tdsdk/oauthCallback", network: .legacy(.TESTNET), enableOneKey: true, web3AuthClientId: "CLIENT ID")

        Task {
            do {
                let customAuth = try CustomAuth(config: options)

                let keyDetails = try await customAuth.triggerLogin(args: sub)

                user = User(publicAddress: keyDetails.torusKey.finalKeyData.evmAddress, privateKey: keyDetails.torusKey.finalKeyData.privKey, userInfo: keyDetails.singleVerifierResponse.userInfo)
            } catch {
                print(error)
            }
        }
    }

    func twitchLogin() {
        let sub = SubVerifierDetails(typeOfLogin: .twitch, verifier: "twitch-shubs", clientId: "p560duf74b2bidzqu6uo0b3ot7qaao", redirectURL: "https://scripts.toruswallet.io/redirect.html")

        let options = CustomAuthArgs(urlScheme: "tdsdk://tdsdk/oauthCallback", network: .legacy(.TESTNET), enableOneKey: true, web3AuthClientId: "CLIENT ID")

        Task {
            do {
                let customAuth = try CustomAuth(config: options)

                let keyDetails = try await customAuth.triggerLogin(args: sub)

                user = User(publicAddress: keyDetails.torusKey.finalKeyData.evmAddress, privateKey: keyDetails.torusKey.finalKeyData.privKey, userInfo: keyDetails.singleVerifierResponse.userInfo)
            } catch {
                print(error)
            }
        }
    }

    func twitterLogin() {
        let sub = SubVerifierDetails(typeOfLogin: .twitter, verifier: "torus-auth0-twitter-lrc", clientId: "A7H8kkcmyFRlusJQ9dZiqBLraG2yWIsO", redirectURL: "https://scripts.toruswallet.io/redirect.html")

        let options = CustomAuthArgs(urlScheme: "tdsdk://tdsdk/oauthCallback", network: .legacy(.TESTNET), enableOneKey: true, web3AuthClientId: "CLIENT ID")

        Task {
            do {
                let customAuth = try CustomAuth(config: options)

                let keyDetails = try await customAuth.triggerLogin(args: sub)

                user = User(publicAddress: keyDetails.torusKey.finalKeyData.evmAddress, privateKey: keyDetails.torusKey.finalKeyData.privKey, userInfo: keyDetails.singleVerifierResponse.userInfo)
            } catch {
                print(error)
            }
        }
    }

    func githubLogin() {
        let sub = SubVerifierDetails(typeOfLogin: .github, verifier: "torus-auth0-github-lrc", clientId: "PC2a4tfNRvXbT48t89J5am0oFM21Nxff", redirectURL: "https://scripts.toruswallet.io/redirect.html")

        let options = CustomAuthArgs(urlScheme: "tdsdk://tdsdk/oauthCallback", network: .legacy(.TESTNET), enableOneKey: true, web3AuthClientId: "CLIENT ID")

        Task {
            do {
                let customAuth = try CustomAuth(config: options)

                let keyDetails = try await customAuth.triggerLogin(args: sub)

                user = User(publicAddress: keyDetails.torusKey.finalKeyData.evmAddress, privateKey: keyDetails.torusKey.finalKeyData.privKey, userInfo: keyDetails.singleVerifierResponse.userInfo)
            } catch {
                print(error)
            }
        }
    }

    func linkedinLogin() {
        let sub = SubVerifierDetails(typeOfLogin: .linkedin, verifier: "torus-auth0-linkedin-lrc", clientId: "59YxSgx79Vl3Wi7tQUBqQTRTxWroTuoc", redirectURL: "https://scripts.toruswallet.io/redirect.html")

        let options = CustomAuthArgs(urlScheme: "tdsdk://tdsdk/oauthCallback", network: .legacy(.TESTNET), enableOneKey: true, web3AuthClientId: "CLIENT ID")

        Task {
            do {
                let customAuth = try CustomAuth(config: options)

                let keyDetails = try await customAuth.triggerLogin(args: sub)

                user = User(publicAddress: keyDetails.torusKey.finalKeyData.evmAddress, privateKey: keyDetails.torusKey.finalKeyData.privKey, userInfo: keyDetails.singleVerifierResponse.userInfo)
            } catch {
                print(error)
            }
        }
    }

    func appleLogin() {
        let sub = SubVerifierDetails(typeOfLogin: .apple, verifier: "torus-auth0-apple-lrc", clientId: "m1Q0gvDfOyZsJCZ3cucSQEe9XMvl9d9L", redirectURL: "https://scripts.toruswallet.io/redirect.html")

        let options = CustomAuthArgs(urlScheme: "tdsdk://tdsdk/oauthCallback", network: .legacy(.TESTNET), enableOneKey: true, web3AuthClientId: "CLIENT ID")

        Task {
            do {
                let customAuth = try CustomAuth(config: options)

                let keyDetails = try await customAuth.triggerLogin(args: sub)

                user = User(publicAddress: keyDetails.torusKey.finalKeyData.evmAddress, privateKey: keyDetails.torusKey.finalKeyData.privKey, userInfo: keyDetails.singleVerifierResponse.userInfo)
            } catch {
                print(error)
            }
        }
    }

    func weiboLogin() {
        let sub = SubVerifierDetails(
            typeOfLogin: .weibo,
            verifier: "torus-auth0-weibo-lrc",
            clientId: "dhFGlWQMoACOI5oS5A1jFglp772OAWr1",
            redirectURL: "tdsdk://tdsdk/oauthCallback")

        let options = CustomAuthArgs(urlScheme: "tdsdk://tdsdk/oauthCallback", network: .legacy(.TESTNET), enableOneKey: true, web3AuthClientId: "CLIENT ID")

        Task {
            do {
                let customAuth = try CustomAuth(config: options)

                let keyDetails = try await customAuth.triggerLogin(args: sub)

                user = User(publicAddress: keyDetails.torusKey.finalKeyData.evmAddress, privateKey: keyDetails.torusKey.finalKeyData.privKey, userInfo: keyDetails.singleVerifierResponse.userInfo)
            } catch {
                print(error)
            }
        }
    }
    
    func emailPasswordLogin() {
        let sub = SubVerifierDetails(
            typeOfLogin: .email_password,
            verifier: "torus-auth0-email-password",
            clientId: "sqKRBVSdwa4WLkaq419U7Bamlh5vK1H7",
            redirectURL: "tdsdk://tdsdk/oauthCallback",
            jwtParams: Auth0ClientOptions(
                connection: "Username-Password-Authentication",
                domain: "torus-test.auth0.com",
                verifierIdField: "name"))

        let options = CustomAuthArgs(urlScheme: "tdsdk://tdsdk/oauthCallback", network: .legacy(.TESTNET), enableOneKey: true, web3AuthClientId: "BPi5PB_UiIZ-cPz1GtV5i1I2iOSOHuimiXBI0e-Oe_u6X3oVAbCiAZOTEBtTXw4tsluTITPqA8zMsfxIKMjiqNQ")

        Task {
            do {
                let customAuth = try CustomAuth(config: options)

                let keyDetails = try await customAuth.triggerLogin(args: sub)

                user = User(publicAddress: keyDetails.torusKey.finalKeyData.evmAddress, privateKey: keyDetails.torusKey.finalKeyData.privKey, userInfo: keyDetails.singleVerifierResponse.userInfo)
            } catch {
                print(error)
            }
        }
    }
}
