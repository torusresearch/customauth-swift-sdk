# customauth-swift-sdk

## Introduction

This repo allows iOS applications to retrieve keys stored on the Torus Network
directly. The attestation layer for the Torus Network is generalizable, below is
an example of how to access keys via the SDK via Google. You can read more about
interactions with the Torus Network
[here](https://medium.com/toruslabs/key-assignments-resolution-and-retrieval-afb984500612).

## Features

- All API's return Promises (mxcl/PromiseKit). You can import
  "yannickl/AwaitKit" to convert APIs to async/await format.

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
        .package(name: "CustomAuth", url: "https://github.com/torusresearch/customauth-swift-sdk", from: "2.4.0"))
    ]
)
```

#### Cocoapods

```ruby
pod 'CustomAuth', '~> 4.1.1'
```

#### Manual import or other packages

If you require a package manager other than SPM or Cocoapods, do reach out to
hello@tor.us or alternatively clone the repo manually and import as a framework
in your project

### 2. Initialization

Initalize the SDK depending on the login you require. The example below does so
for a single google login. `redirectURL` refers to a url for the login flow to
redirect into your app, it should have a scheme that is registered by your app,
for example `com.mycompany.myapp://redirect`. `browserRedirectURL` refers to a
page that the browser should use in the login flow, it should have a http or
https scheme.

```swift
import CustomAuth

let sub = SubVerifierDetails(loginType: .installed, // default .web
                            loginProvider: .google,
                            clientId: "<your-client-id>",
                            verifierName: "<verifier-name>",
                            redirectURL: "<your-redirect-url>",
                            browserRedirectURL: "<your-browser-redirect-url>")

let tdsdk = CustomAuth(aggregateVerifierType: "<type-of-verifier>", aggregateVerifierName: "<verifier-name>", subVerifierDetails: [sub], network: <etherum-network-to-use>)

// controller is used to present a SFSafariViewController.
tdsdk.triggerLogin(controller: <UIViewController>?, browserType: <method-of-opening-browser>, modalPresentationStyle: <style-of-modal>).done{ data in
    print("private key rebuild", data)
}.catch{ err in
    print(err)
}
```

Logins are dependent on verifier scripts/verifiers. There are other verifiers
including `single_id_verifier`, `and_aggregate_verifier`,
`or_aggregate_verifier` and `single_logins` of which you may need to use
depending on your required logins. To get your application's verifier script
setup, do reach out to hello@tor.us or to read more about verifiers do checkout
[the docs](https://docs.tor.us/customauth/supported-authenticators-verifiers).

### 3. Handling the OAuth/Authentication URL redirects

You can setup the redirect in two ways; URL Schemes or Universal links.
Typically we recommend users to use URL Schemes as Universal Links require an
additional user interaction. The `handle(url: URL)` class method implements a
NSNotification to handle URL callbacks.

#### Setting up URL Schemes

In the info tab of your target, add your application name (ex. my-wallet-app).
Add the redirect URL to the list of allowed redirect URLs in the OAuth providers
settings page.

- For SwiftUI, without using delegate (iOS 14+)

```swift
.onOpenURL { url in
    guard let url = URLContexts.first?.url else {
        return
    }
    CustomAuth.handle(url: url)
}
```

- For SwiftUI, implement the following in your SceneDelegate

```swift
func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    guard let url = URLContexts.first?.url else {
        return
    }
    CustomAuth.handle(url: url)
}
```

- For Storyboard, implement the following in your app AppDelegate:

```swift
func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    if url.host == "my-wallet-app" {
        CustomAuth.handle(url: url)
    }
    return true
}
```

#### Universal Links

Universal Links allow your users to intelligently follow links to content inside
your app or to your website. Checkout
[Documentation](https://developer.apple.com/ios/universal-links/) for
implementation.

- For Swift UI,

```swift
func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
    guard userActivity.activityType == NSUserActivityTypeBrowsingWeb, let urlToOpen = userActivity.webpageURL else {
        return
    }
    CustomAuth.handle(url: urlToOpen)
}
```

- For Storyboard,

```swift
func application(_ application: UIApplication, continue userActivity: UIUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool
{
    // Get URL components from the incoming user activity
    guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
        let incomingURL = userActivity.webpageURL,
        let components = NSURLComponents(url: incomingURL, resolvingAgainstBaseURL: true) else {
            return false
    }
    CustomAuth.handle(url: incomingURL)
}

```

After this you're good to go, reach out to hello@tor.us to get your verifier
spun up on the testnet today!

## Requirements

- Swift 5

## Using CustomAuthFactory

The `CASDKFactoryProtocol` provides a way to modify the mechanism of discovering
torus nodes in `FetchNodeDetails` and performing key retrieval in `TorusUtils`,
which can be useful in scenarios such as mocking or advanced customization.
Developers who want to use this mechanism should implement
`CASDKFactoryProtocol` in Sources/CustomAuth/CustomAuth.swift, and then pass the
instance into the `init` of `CustomAuth`, for example:

```swift
let tdsdk = CustomAuth(
    aggregateVerifierType: "<type-of-verifier>",
    aggregateVerifierName: "<verifier-name>",
    subVerifierDetails: [sub],
    factory: customFactory,
    network: myNetworkm
    loglevel: myLoglevel
)
```

## 💬 Troubleshooting and Discussions

- Have a look at our
  [GitHub Discussions](https://github.com/Web3Auth/Web3Auth/discussions?discussions_q=sort%3Atop)
  to see if anyone has any questions or issues you might be having.
- Checkout our
  [Troubleshooting Documentation Page](https://web3auth.io/docs/troubleshooting)
  to know the common issues and solutions
- Join our [Discord](https://discord.gg/web3auth) to join our community and get
  private integration support or help with your integration.
