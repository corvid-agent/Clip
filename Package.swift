// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Clip",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "Clip", targets: ["Clip"])
    ],
    targets: [
        .executableTarget(
            name: "Clip",
            path: "Sources/Clip"
        ),
        .testTarget(
            name: "ClipTests",
            dependencies: ["Clip"],
            path: "Tests/ClipTests"
        )
    ]
)
