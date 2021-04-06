Pod::Spec.new do |spec|
  spec.name         = "Torus-directSDK"
  spec.version      = "0.3.1"
  spec.platform = :ios, "10.0"
  spec.summary      = "Swift SDK that allows applications to directly interact with the Torus Network, similar to how Torus Wallet does."
  spec.homepage     = "https://github.com/torusresearch/torus-direct-swift-sdk"
  spec.license      = { :type => 'BSD', :file => 'License.md' }
  spec.swift_version   = "5.0"
  spec.author       = { "Torus Labs" => "rathishubham017@gmail.com" }
  spec.module_name = "TorusSwiftDirectSDK"
  spec.source       = { :git => "https://github.com/torusresearch/torus-direct-swift-sdk.git", :tag => spec.version }
  spec.source_files = "Sources/TorusSwiftDirectSDK/*.{swift}","Sources/TorusSwiftDirectSDK/**/*.{swift}"
  spec.dependency 'BestLogger', '~> 0.0.1'
  spec.dependency 'Torus-utils', '~> 0.1.0'
  spec.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  spec.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
end
