// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SyncOneWay",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "SyncOneWay", targets: ["SyncOneWay"])
    ],
    targets: [
        .executableTarget(
            name: "SyncOneWay",
            path: "SyncOneWay"
        ),
        .testTarget(
            name: "SyncOneWayTests",
            dependencies: ["SyncOneWay"],
            path: "Tests/SyncOneWayTests"
        )
    ]
)
