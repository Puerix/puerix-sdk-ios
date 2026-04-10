# PuerixSDK — iOS

Native iOS SDK for age verification with liveness detection and document capture.

## Installation

### CocoaPods

```ruby
pod 'PuerixSDK', :git => 'https://github.com/Puerix/puerix-sdk-ios.git', :tag => '0.1.0'
```

### Swift Package Manager

In Xcode: **File > Add Package Dependencies** and enter:

```
https://github.com/Puerix/puerix-sdk-ios.git
```

> **Note:** Google ML Kit does not support SPM. Install it separately via CocoaPods:
> ```ruby
> pod 'GoogleMLKit/FaceDetection', '~> 6.0'
> ```

## Usage

```swift
import PuerixSDK

// 1. Initialize
PuerixSDK.shared.initialize(config: PuerixConfig(apiKey: "YOUR_API_KEY"))

// 2. Start verification
PuerixSDK.shared.startVerification(
    from: self,
    subject: "user-123",
    ageLimit: 18
) { result in
    if result.isApproved {
        print("Approved! Session: \(result.sessionId)")
    }
}
```

## Requirements

- iOS 13.0+
- Xcode 14+
- API key from [puerix.com](https://puerix.com)

## License

Copyright (c) 2024 Puerix. All rights reserved. Proprietary license.
