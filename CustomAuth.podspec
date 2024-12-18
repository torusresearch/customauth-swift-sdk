Pod::Spec.new do |spec|
  spec.name         = "CustomAuth"
  spec.version      = "11.0.2"
  spec.platform = :ios, "14.0"
  spec.summary      = "Swift SDK that allows applications to directly interact with the Torus Network, similar to how Torus Wallet does."
  spec.homepage     = "https://github.com/torusresearch/customauth-swift-sdk"
  spec.license      = { :type => 'BSD', :file  => 'License.md' }
  spec.swift_version   = "5.3"
  spec.author       = { "Torus Labs" => "hello@tor.us" }
  spec.module_name = "CustomAuth"
  spec.source       = { :git => "https://github.com/torusresearch/customauth-swift-sdk.git", :tag => spec.version }
  spec.source_files = "Sources/CustomAuth/*.{swift}","Sources/CustomAuth/**/*.{swift}"
  spec.dependency 'Torus-utils', '~> 10.0.0'
  spec.dependency 'JWTDecode', '~> 3.2.0'
end
