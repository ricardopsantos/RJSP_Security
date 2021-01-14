// swift-tools-version:5.2
import PackageDescription

let appName = "App"

let swiftSettings: SwiftSetting = .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release))
let serverTargetDependency: Target.Dependency = .product(name: "Vapor", package: "vapor")

//
// ####### Dependencies init
//
let rjpsSecurityDependency: Target.Dependency = .product(name: "RJSecurity", package: "rjs-security")

//
// ####### Dependencies end
//

let dependencies = [serverTargetDependency, rjpsSecurityDependency]

let package = Package(
    name: appName,
    platforms: [.macOS(.v10_15)],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.36.0"),
        .package(name: "rjs-security", url: "https://github.com/ricardopsantos/RJSP_Security", from: "1.0.0")
    ],
    targets: [
        .target(name: appName, dependencies: dependencies, swiftSettings: [swiftSettings]),
        .target(name: "Run", dependencies: [.target(name: appName)]),
        .testTarget(name: "AppTests", dependencies: [.target(name: "App"), .product(name: "XCTVapor", package: "vapor"),])
    ]
)
