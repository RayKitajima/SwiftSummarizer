// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftSummarizer",
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
		//.package(name: "Reductio", path: "../Reductio"),
        .package(url: "https://github.com/RayKitajima/Reductio.git", from: "1.4.12"),
        .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "2.5.3")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .executableTarget(
            name: "SwiftSummarizer",
            dependencies: ["Reductio","SwiftSoup"]),
        .testTarget(
            name: "SwiftSummarizerTests",
            dependencies: ["Reductio","SwiftSummarizer"]),
    ]
)
