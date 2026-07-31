// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "liquid_flutter_window_utils",
    platforms: [
        .macOS("12.0"),
    ],
    products: [
        .library(name: "liquid-flutter-window-utils", targets: ["liquid_flutter_window_utils"]),
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
    ],
    targets: [
        .target(
            name: "liquid_flutter_window_utils",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
            ],
            resources: [
                .process("Resources"),
            ],
        ),
    ],
)
