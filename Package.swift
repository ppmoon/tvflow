// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "TVFlowCore",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "TVFlowCore",
            targets: ["TVFlowCore"]
        )
    ],
    targets: [
        .target(
            name: "TVFlowCore"
        ),
        .testTarget(
            name: "TVFlowCoreTests",
            dependencies: ["TVFlowCore"]
        )
    ]
)
