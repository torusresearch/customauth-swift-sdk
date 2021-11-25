Pod::Spec.new do |spec|
  spec.name         = "CustomAuth"
  spec.version      = "2.2.0"
  spec.platform = :ios, "11.0"
  spec.summary      = "Swift SDK that allows applications to directly interact with the Torus Network, similar to how Torus Wallet does."
  spec.homepage     = "https://github.com/torusresearch/customauth-swift-sdk"
  spec.license      = { :type => 'BSD', :file  => 'License.md' }
  spec.swift_version   = "5.0"
  spec.author       = { "Torus Labs" => "rathishubham017@gmail.com" }
  spec.module_name = "CustomAuth"
  spec.source       = { :git => "https://github.com/torusresearch/customauth-swift-sdk.git", :tag => spec.version }
  spec.source_files = "Sources/CustomAuth/*.{swift}","Sources/CustomAuth/**/*.{swift}"
  spec.dependency 'Torus-utils', '~> 1.2.0'
end
