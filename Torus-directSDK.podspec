Pod::Spec.new do |spec|
  spec.name         = "Torus-directSDK"
  spec.version      = "1.2.0"
  spec.platform = :ios, "11.0"
  spec.summary      = "Swift SDK that allows applications to directly interact with the Torus Network, similar to how Torus Wallet does."
  spec.homepage     = "https://github.com/torusresearch/torus-direct-swift-sdk"
  spec.license      = { :type => 'BSD', :file => 'License.md' }
  spec.swift_version   = "5.0"
  spec.author       = { "Torus Labs" => "rathishubham017@gmail.com" }
  spec.module_name = "TorusSwiftDirectSDK"
  spec.source       = { :git => "https://github.com/torusresearch/torus-direct-swift-sdk.git", :tag => spec.version }
  spec.source_files = "Sources/TorusSwiftDirectSDK/*.{swift}","Sources/TorusSwiftDirectSDK/**/*.{swift}"
  spec.dependency 'Torus-utils', '~> 1.2.0'
end
