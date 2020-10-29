#
#  Created by teambition-ios on 2020/7/27.
#  Copyright © 2020 teambition. All rights reserved.
#     

Pod::Spec.new do |s|
  s.name             = 'AMRAudioSwift'
  s.version          = '0.2.5'
  s.summary          = 'AMRAudioSwift is a useful tool to encode or decode audio between AMR and WAVE.'
  s.description      = <<-DESC
  AMRAudioSwift is a useful tool to encode or decode audio between AMR and WAVE. It's written in Swift, and it supports Bitcode.

  In addition, AMRAudioSwift contains an audio recorder/player, which can record voice and play AMR data.
  
  At the bottom level, libopencore-amr is applied for audio decoding.
                       DESC

  s.homepage         = 'https://github.com/teambition/AMRAudioSwift'
  s.license          = { :type => 'MIT', :file => 'LICENSE.md' }
  s.author           = { 'teambition mobile' => 'teambition-mobile@alibaba-inc.com' }
  s.source           = { :git => 'https://github.com/teambition/AMRAudioSwift.git', :tag => s.version.to_s }

  s.swift_version = '5.0'
  s.ios.deployment_target = '10.0'

  s.source_files = 'AMRAudioSwift/*.swift', 'AMRAudioSwift/Source/*.{h,m}'
  s.vendored_libraries = 'AMRAudioSwift/Source/libopencore-amrnb.a'

end
