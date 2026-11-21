// swift-tools-version: 6.3
import PackageDescription

let cadovaSettings: [SwiftSetting] = [.interoperabilityMode(.Cxx)]

let package = Package(
    name: "ConnectorKit",
    platforms: [.macOS(.v15)],
    products: [
        .library(name: "ConnectorKit", targets: ["ConnectorKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/tomasf/Cadova.git", from: "1.3.0"),
        .package(url: "https://github.com/tomasf/Helical.git", from: "1.2.0"),
    ],
    targets: [
        .target(
            name: "ConnectorKit",
            dependencies: ["Cadova", "Helical"],
            swiftSettings: cadovaSettings
        ),
        .executableTarget(
            name: "Connectors",
            dependencies: ["ConnectorKit", "Cadova"],
            swiftSettings: cadovaSettings
        ),
        .testTarget(
            name: "ConnectorKitTests",
            dependencies: ["ConnectorKit", "Cadova", "Helical"],
            swiftSettings: cadovaSettings
        ),
    ]
)
