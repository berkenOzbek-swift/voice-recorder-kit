// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "voice-recorder-kit",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "voice-recorder-kit",
            targets: ["voice-recorder-kit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/SnapKit/SnapKit.git", .upToNextMajor(from: "5.0.1"))
    ],
    targets: [
        .target(
            name: "voice-recorder-kit",
            dependencies: [
                "SnapKit"
            ]
        )
    ]
)
