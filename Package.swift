// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "PuerixSDK",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "PuerixSDK",
            targets: ["PuerixSDK"]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "PuerixSDK",
            path: "PuerixSDK.xcframework"
        ),
    ]
)

// NOTE: Google ML Kit does not support Swift Package Manager.
// Install GoogleMLKit/FaceDetection separately via CocoaPods:
//
//   pod 'GoogleMLKit/FaceDetection', '~> 6.0'
