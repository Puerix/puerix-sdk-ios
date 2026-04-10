// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "PuerixSDK",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "PuerixAuth",
            targets: ["PuerixAuth"]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "PuerixAuth",
            path: "PuerixAuth.xcframework"
        ),
    ]
)
