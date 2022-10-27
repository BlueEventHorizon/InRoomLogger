// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "InRoomLogger",
    platforms: [
        .iOS(.v11),
        .macOS(.v10_15),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "InRoomLogger",
            targets: ["InRoomLogger"]),
    ],
    dependencies: [
        .package(url: "https://github.com/BlueEventHorizon/BwLogger", from: "5.0.0"),
        .package(url: "https://github.com/BlueEventHorizon/BwNearPeer", from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "InRoomLogger",
            dependencies: ["BwLogger", "BwNearPeer"]),
        .testTarget(
            name: "InRoomLoggerTests",
            dependencies: ["InRoomLogger"]),
    ]
)
