// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EasyAlbum",
    platforms: [.iOS(.v10)],
    products: [
        .library(name: "EasyAlbum", targets: ["EasyAlbum"]),
    ],
    targets: [
        .target(
            name: "EasyAlbum",
            dependencies: [],
            path: "Sources"),
        .testTarget(
            name: "EasyAlbumTests",
            dependencies: ["EasyAlbum"]),
    ],
    swiftLanguageVersions: [.v5]
)
