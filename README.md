# Taylor [![Version](https://img.shields.io/cocoapods/v/Taylor.svg?style=flat)](http://cocoapods.org/pods/Taylor) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) [![Slack Status](https://taylor-framework.herokuapp.com/badge.svg)](https://taylor-framework.herokuapp.com)

### Disclaimer: Not actively working on it anymore. You can check out [some](https://github.com/qutheory/vapor) [alternatives](https://github.com/IBM-Swift/Kitura)

Swift 2.0 required. Working with Xcode 7.1.

Disclaimer: It is a work in progress, it may break. Use it at your own risk.

Taylor is a library which allows you to create web server applications in [Swift](https://developer.apple.com/swift/)

## Status
At this moment, Taylor only supports GET, POST and PUT HTTP requests. Better documentation is on the way.

## Hello World

```swift

import Taylor

let server = Taylor.Server()

server.get("/") { req, res in
    res.bodyString = "Hello, world!"
    return .Send
}

let port = 3002
do {
   print("Starting server on port: \(port)")
   try server.serveHTTP(port: port, forever: true)
} catch {
   print("Server start failed \(error)")
}
```

More advanced usage instructions coming soon!

## Playground
The easiest way to try out Taylor is using a playground.

For this, you need to have Carthage installed in your computer, is what it is used for fetching the dependencies.

```sh
$ git clone https://github.com/izqui/Taylor.git -b playground
$ cd taylor
$ sh setup.sh
```

And that's it, you should be good to go. Have fun!

## Usage
You can use Taylor from the command line using [CocoaPods Rome](https://github.com/neonichu/Rome) or [Carthage](https://github.com/Carthage/Carthage) as dependency managers.

### Carthage
Create a `Cartfile`:

```
github "izqui/taylor"
```

And then run:

```sh
$ carthage update
$ xcrun swift -F Carthage/Build/Mac yourfile.swift
```

### CocoaPods Rome
Create a `Podfile`:

```
platform :osx, '10.10'

plugin 'cocoapods-rome'

pod 'Taylor'
```

And then run:

```sh
$ pod install
$ xcrun swift -F Rome yourfile.swift
```

Credits to [Ayaka Nonaka](https://twitter.com/ayanonagon)'s [Swift Summit](http://swiftsummit.com) talk for sharing this method for doing Scripting in Swift

## Dependencies
Right now Taylor relies on an Swift library called [SwiftSockets](https://github.com/AlwaysRightInstitute/SwiftSockets/).

## Development
Join our Slack [![Slack Status](https://taylor-framework.herokuapp.com/badge.svg)](https://taylor-framework.herokuapp.com)

For the development of the Taylor framework we use Carthage for managing dependencies.

To contribute to Taylor, clone the project on your local machine and run:

```sh
$ carthage bootstrap
```

Then you can open `Taylor.xcodeproj` and start developing.

The reason there is a Mac app inside the project is for testing purposes given that you cannot have frameworks linked with a Command Line application in Xcode using Carthage. See [here](https://github.com/Carthage/Carthage/issues/287).

## Inspiration
- [Go's Martini](https://github.com/go-martini/martini)
- [Barista](https://github.com/SteveStreza/barista)
