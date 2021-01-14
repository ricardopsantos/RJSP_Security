// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "rjs-security",
    platforms: [.iOS(.v13), .macOS(.v10_15)],
    products: [
        .library(name: "RJSecurity", targets: ["RJSecurity"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "RJSecurity", dependencies: []),
        .testTarget(
            name: "RJSecurityTests",
            dependencies: ["RJSecurity"]),
    ]
)
