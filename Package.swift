// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GhostRoll",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "GhostRoll",
            targets: ["GhostRoll"]),
    ],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "10.0.0")
    ],
    targets: [
        .target(
            name: "GhostRoll",
            dependencies: [
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseCore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk")
            ],
            path: "GhostRoll"
        ),
        .testTarget(
            name: "GhostRollTests",
            dependencies: ["GhostRoll"]),
    ]
)
