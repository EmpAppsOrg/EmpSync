// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "EmpSync",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(
            name: "EmpSync",
            targets: ["EmpSync"],
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/EmpAppsOrg/EmpCore.git", from: "0.1.0"),
    ],
    targets: [
        .target(
            name: "EmpSync",
            dependencies: ["EmpCore"],
        ),
        .testTarget(
            name: "EmpSyncTests",
            dependencies: ["EmpSync"],
        ),
    ],
)
