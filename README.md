# customauth-swift-sdk

## Introduction

This repo allows iOS applications to retrieve keys stored on the Torus Network
directly. The attestation layer for the Torus Network is generalizable, below is
an example of how to access keys via the SDK via Google. You can read more about
interactions with the Torus Network
[here](https://medium.com/toruslabs/key-assignments-resolution-and-retrieval-afb984500612).

## 🩹 Examples

Checkout the example of `CustomAuth iOS/Swift SDK` in our
[CustomAuthDemo directory.](https://github.com/torusresearch/customauth-swift-sdk/tree/master/CustomAuthDemo)

## Usage

### 1. Installation

#### Swift package manager

In project settings, add the Github URL as a swift package dependency.

```swift
import PackageDescription

let package = Package(
    name: "CustomAuth",
    dependencies: [
        .package(name: "CustomAuth", url: "https://github.com/torusresearch/customauth-swift-sdk", from: "11.0.0"))
    ]
)
```

#### Cocoapods

```ruby
pod 'CustomAuth', '~> 11.0.0'
```

### 2. Initialization and Login

Initalize the SDK depending and then you can use the login you require.

```swift
import CustomAuth

let config = CustomAuthArgs(urlScheme: "<your-whitelisted-url-scheme", network: <TorusNetwork>, enableOneKey: true, web3AuthClientId: "your-web3auth-client-id")
   
   
let customAuth = try CustomAuth(config: config)
                    
```

The example login below does so for a single google login. `redirectURL` refers to url for the login flow to
redirect back to your app, it should use the scheme known to your application.


```
let sub = SingleLoginParams(typeOfLogin: .google, verifier: "<your-google-social-verifier>", clientId: "<your-google-application-client-id>", redirectURL: "<your-redirect-url?")

Task {
    do {
        let torusKey = try await customAuth.triggerLogin(args: sub)
    } catch {
        print(error)
    }
}
```

Logins are dependent on verifier scripts/verifiers. There are other verifiers
including `single_id_verifier`, `and_aggregate_verifier`,
`or_aggregate_verifier` and `single_logins` of which you may need to use
depending on your required logins. To get your application's verifier script
setup, do reach out to hello@tor.us or to read more about verifiers do checkout
[the docs](https://docs.tor.us/customauth/supported-authenticators-verifiers).

### 3. Handling the OAuth/Authentication URL redirects

You can setup the redirectURL using URL Schemes and adding the relevant URLScheme to URL Types for your project. This package makes use of ASWebAuthenticationSession underneath and is done in such a way that it can provide its' own presentation context if necessary.

## Requirements

- Swift 5

## 💬 Troubleshooting and Discussions

- Have a look at our
  [GitHub Discussions](https://github.com/Web3Auth/Web3Auth/discussions?discussions_q=sort%3Atop)
  to see if anyone has any questions or issues you might be having.
- Checkout our
  [Troubleshooting Documentation Page](https://web3auth.io/docs/troubleshooting)
  to know the common issues and solutions
- Join our [Discord](https://discord.gg/web3auth) to join our community and get
  private integration support or help with your integration.
