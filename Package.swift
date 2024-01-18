// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "audioviz",
    platforms: [.macOS(.v14)],
    products: [.executable(name: "audioviz", targets: ["audioviz"])],
    dependencies: [
        .package(url: "https://github.com/rensbreur/SwiftTUI.git", revision: "9ae1ac9")
    ],
    targets: [
        .executableTarget(
            name: "audioviz",
            dependencies: [
                .product(name: "SwiftTUI", package: "SwiftTUI")
            ],
            linkerSettings: [
                .unsafeFlags([
                    "-Xlinker", "-sectcreate",
                    "-Xlinker", "__TEXT",
                    "-Xlinker", "__info_plist",
                    "-Xlinker", "Sources/Resources/Info.plist"
                ])
            ]
        ),
    ]
)
