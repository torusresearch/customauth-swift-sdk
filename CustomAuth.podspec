Pod::Spec.new do |spec|
  spec.name         = "CustomAuth"
  spec.version      = "7.0.0"
  spec.platform = :ios, "13.0"
  spec.summary      = "Swift SDK that allows applications to directly interact with the Torus Network, similar to how Torus Wallet does."
  spec.homepage     = "https://github.com/torusresearch/customauth-swift-sdk"
  spec.license      = { :type => 'BSD', :file  => 'License.md' }
  spec.swift_version   = "5.3"
  spec.author       = { "Torus Labs" => "rathishubham017@gmail.com" }
  spec.module_name = "CustomAuth"
  spec.source       = { :git => "https://github.com/torusresearch/customauth-swift-sdk.git", :tag => spec.version }
  spec.source_files = "Sources/CustomAuth/*.{swift}","Sources/CustomAuth/**/*.{swift}"
  spec.dependency 'Torus-utils', '~> 6.1.0'
  spec.dependency 'JWTDecode', '~> 3.0.1'
end
