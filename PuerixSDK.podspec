Pod::Spec.new do |s|
  s.name             = 'PuerixSDK'
  s.version          = '0.1.0'
  s.summary          = 'Puerix SDK — age verification with liveness detection and document capture.'
  s.description      = <<-DESC
    Native iOS SDK for age verification.
    Includes liveness detection (face tracking, head turns),
    document capture with OCR (CPF extraction),
    image quality validation, and full API integration.
  DESC
  s.homepage         = 'https://puerix.com'
  s.license          = { :text => 'Copyright (c) 2024 Puerix. All rights reserved.', :type => 'Proprietary' }
  s.author           = { 'Puerix' => 'dev@puerix.com' }
  s.source           = { :git => 'https://github.com/Puerix/puerix-sdk-ios.git', :tag => s.version.to_s }

  s.platform         = :ios, '13.0'
  s.swift_version    = '5.7'

  # Closed-source binary — no Swift source included
  s.vendored_frameworks = 'PuerixSDK.xcframework'

  # Runtime dependency
  s.dependency 'GoogleMLKit/FaceDetection', '~> 6.0'

  s.frameworks = 'AVFoundation', 'UIKit', 'Vision', 'CoreGraphics'

  s.pod_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
  }
end
