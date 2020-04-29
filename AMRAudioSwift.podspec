Pod::Spec.new do |spec|
  spec.name = "AMRAudioSwift"
  spec.version = "0.2.3"
  spec.summary = "A useful tool to encode or decode audio between AMR and WAVE."

  spec.homepage = "https://github.com/teambition/AMRAudioSwift"
  spec.license = { :type => "MIT", :file => "LICENSE.md" }
  spec.author = { "Teambition" => "dev@teambition.com" }
  
  spec.swift_version = '5.0'
  spec.platform = :ios
  spec.ios.deployment_target = "10.0"
  
  spec.source = { :git => "https://github.com/teambition/AMRAudioSwift.git", :tag => "#{spec.version}" }
  spec.source_files = "AMRAudioSwift/**/*.{h,m,swift}"
  spec.ios.vendored_library = 'AMRAudioSwift/**/*.{a}'
end
