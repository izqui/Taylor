import PackageDescription

let package = Package(
    name: "Taylor",
    targets: [
	Target(name: "Taylor"),
	Target(name: "Example", dependencies: [.Target(name: "Taylor")])
	],
    dependencies: [
        .Package(url: "https://github.com/izqui/SwiftSockets.git",
                 majorVersion: 0)
    ]
)
