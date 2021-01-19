// swift-tools-version:5.2
import PackageDescription

let appName = "WebServer"

let swiftSettings: SwiftSetting = .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release))
let vaporTargetDependency: Target.Dependency = .product(name: "Vapor", package: "vapor")
let rjpsSecurityTargetDependency: Target.Dependency = .product(name: "RJSecurity", package: "rjs-security")

var dependencies = [vaporTargetDependency]
dependencies.append(rjpsSecurityTargetDependency)

let rjSecurityMasterPackageDepedency: Package.Dependency  = .package(name: "rjs-security", url: "https://github.com/ricardopsantos/RJSP_Security", .branch("master"))
let rjSecurityDevelopPackageDepedency: Package.Dependency = .package(name: "rjs-security", url: "https://github.com/ricardopsantos/RJSP_Security", .branch("develop"))
let rjSecurityCurrentPackageDepedency: Package.Dependency = .package(name: "rjs-security", url: "https://github.com/ricardopsantos/RJSP_Security", .upToNextMajor(from: "1.2.0"))
let rjSecurityPackageDepedency = rjSecurityCurrentPackageDepedency

let package = Package(
    name: appName,
    platforms: [.macOS(.v10_15)],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.36.0"),
        rjSecurityPackageDepedency
    ],
    targets: [
        .target(name: appName, dependencies: dependencies, swiftSettings: [swiftSettings]),
        .target(name: "Run", dependencies: [.target(name: appName)]),
        .testTarget(name: "\(appName)Tests", dependencies: [.target(name: "\(appName)"), .product(name: "XCTVapor", package: "vapor"),])
    ]
)
