# Torus-direct-swift-sdk

## Introduction

This repo allows iOS applications to retrieve keys stored on the Torus Network directly. The attestation layer for the Torus Network is generalizable, below is an example of how to access keys via the SDK via Google.

## Features

- All API's return Promises (mxcl/PromiseKit). You can import "yannickl/AwaitKit" to convert APIs to async/await format.

## Installation

### Swift package manager
In project settings, add the Github URL as a swift package dependency.
```
import PackageDescription

let package = Package(
name: "TorusSwiftDirectSDK",
dependencies: [
.package(name: "OAuthSwift", url: "https://github.com/torusresearch/torus-direct-swift-sdk", .upToNextMajor(from: "0.0.1"))
]
)
```

### Cocoapods
Coming soon

### Manual import

Clone the repo manually and import as a framework in your project


## Usage

### Initialization

We support 4 different types of verifiers. `single_id_verifier`, `and_aggregate_verifier`, `or_aggregate_verifier` and `single_logins`
```
import TorusSwiftDirectSDK

let subVerifierDetails = [["clientId": "876733105116-i0hj3s53qiio5k95prpfmj0hp0gmgtor.apps.googleusercontent.com",
"typeOfLogin": "google",
"verifier": "google"]]

let tdsdk = TorusSwiftDirectSDK(aggregateVerifierType: "single_login", aggregateVerifierName: "google", subVerifierDetails: subVerifierDetails)

tdsdk.triggerLogin()
```

### Handling URL redirects 

A successful login generates an `id_token`, which is required by Torus-utils. There are two ways for this redirect, URL Schemes, and Universal logins

#### Setting up URL Schemes

In the info tab of your target, add your application name (ex. my-wallet-app). Add the redirect URL to the list of allowed redirect URLs in the OAuth providers settings page.

- For SwiftUI, implement the following in your SceneDelegate
```
func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
guard let url = URLContexts.first?.url else {
return
}
TorusSwiftDirectSDK.handle(url: url)
}
```

- For Storyboard, implement the following in your app AppDelegate:
```
func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
if url.host == "my-wallet-app" {
OAuthSwift.handle(url: url)
}
return true
}
```

#### Universal Links

Universal Links allow your users to intelligently follow links to content inside your app or to your website. Checkout [Documentation](https://developer.apple.com/ios/universal-links/) for implementation. 
- For Swift UI,
```
func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
guard userActivity.activityType == NSUserActivityTypeBrowsingWeb, let urlToOpen = userActivity.webpageURL else {
return
}
TorusSwiftDirectSDK.handle(url: urlToOpen)
}
```

- For Storyboard,
```
func application(_ application: UIApplication, continue userActivity: UIUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool
{
// Get URL components from the incoming user activity
guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
let incomingURL = userActivity.webpageURL,
let components = NSURLComponents(url: incomingURL, resolvingAgainstBaseURL: true) else {
return false
}
TorusSwiftDirectSDK.handle(url: incomingURL)

}

```

Reach out to hello@tor.us to get your verifier spun up on the testnet today!


## Requirements
- Swift 5
