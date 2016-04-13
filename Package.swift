import PackageDescription

let package = Package(
    name: "Taylor",
    targets: [],
    dependencies: [
        .Package(url: "https://github.com/izqui/SwiftSockets.git",
                 majorVersion: 0)
    ]
)
