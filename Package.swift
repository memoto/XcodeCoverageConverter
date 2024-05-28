// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import Foundation

var embedResources: Bool {
    ProcessInfo.processInfo.environment["EMBED_RESOURCES"] != nil
}

var resourcesDependency: Target.Dependency {
    embedResources
        ? .target(name: "ResourcesEmbedded")
        : .target(name: "ResourcesBundled")
}

var resourcesTargets: [Target] {
    let embedResources: [Target] = embedResources
        ? [
            .target(name: "ResourcesEmbedded",
                    path: "Sources/Resources/Embedded",
                    publicHeadersPath: "",
                    linkerSettings: [ .unsafeFlags(
                        ["-Xlinker", "-sectcreate",
                         "-Xlinker", "__DATA",
                         "-Xlinker", "__coverage_dtd",
                         "-Xlinker", "Sources/Resources/Bundled/coverage-04.dtd"]
                        // verify if the file is embedded by running
                        // `otool -X -s __DATA __coverage_dtd <path/to/xcc> | xxd -rma`
                    )]),
        ] : []
    let resources: [Target] = [
        .target(name: "Resources",
                path: "Sources/Resources/Main"),
        .target(name: "ResourcesBundled",
                path: "Sources/Resources/Bundled",
                resources: [.copy("coverage-04.dtd")]),
    ]
    
    return embedResources + resources
}

let package = Package(
    name: "XcodeCoverageConverter",
    platforms: [
        .macOS(.v10_13),
    ],
    products: [
        .executable(name: "xcc", targets: ["XcodeCoverageConverter"]),
        .library(name: "XcodeCoverage", targets: ["XcodeCoverage"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .executableTarget(
            name: "XcodeCoverageConverter",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "Core",
                resourcesDependency
            ],
            path: "Sources/XcodeCoverageConverter"),
        .target(
            name: "XcodeCoverage",
            dependencies: ["Core", "ResourcesBundled"]
        ),
        .target(
            name: "Core",
            dependencies: [
                embedResources ? .target(name: "Resources") : .target(name: "ResourcesBundled"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
            path: "Sources/Core",
            swiftSettings: embedResources ? [.define("EMBED_RESOURCES")] : []
        )
    ] + resourcesTargets + [
        // Tests
        .testTarget(
            name: "CoreTests",
            dependencies: ["Core", "ResourcesBundled"],
            path: "Tests/CoreTests")
    ]
)
