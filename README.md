

Taylor [![Version](https://img.shields.io/cocoapods/v/Taylor.svg?style=flat)](http://cocoapods.org/pods/Taylor) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
======

Swift 2.0 required. Working with xCode 7.0 GM.

Disclaimer: It is a work in progress, it may break. Use it at your own risk.

Taylor is a library which allows you to create web server applications in [Swift](https://developer.apple.com/swift/)

## Status

At this moment, Taylor only supports GET, POST and PUT HTTP requests.
Better documentation is on the way.

## Hello World

```.swift

import Taylor

let server = Taylor.Server()

server.get("/") {
    req, res, cb in

    res.bodyString = "Hello, world!"
    cb(.Send(req, res))
}

let port = 3002
do {
   print("Staring server on port: \(port)")
   try server.serveHTTP(port: port, forever: true)
} catch let e {
   print("Server start failed \(e)")
}

```

## Playground

The easiest way to try out Taylor is using a playground.

For this, you need to have Carthage installed in your computer, is what it is used for fetching the dependencies.

```.sh
$ git clone git@github.com:izqui/Taylor.git -b playground
$ cd taylor/
$ sh setup.sh
```

And that's it, you should be good to go. Have fun!

## Usage

You can use Taylor from the command line using [Cocoapods Rome](https://github.com/neonichu/Rome) or [Carthage](https://github.com/Carthage/Carthage) as dependency managers.

#### Carthage

Create a `Cartfile`:
```
github "izqui/taylor"
```

And then run:

```.sh
$ carthage update
$ xcrun swift -F Carthage/Build/Mac yourfile.swift
```

#### CocoaPods Rome

Create a `Podfile`:
```
platform :osx, '10.10'

plugin 'cocoapods-rome'

pod 'Taylor'
```

And then run:
```.sh
$ pod install
$ xcrun swift -F Rome yourfile.swift
```

Credits to [Ayaka Nonaka](https://twitter.com/ayanonagon)'s [Swift Summit](http://swiftsummit.com) talk for sharing this method for doing Scripting in Swift


## Dependencies

Right now Taylor relies on an Objective-C library called [CocoaAsyncSocket](https://github.com/robbiehanson/CocoaAsyncSocket/).

## Development

For the development of the Taylor framework we use Carthage for managining dependencies.

To contribute to Taylor, clone the project on your local machine and run:

```.sh
$ carthage bootstrap
```

Then you can open `Taylor.xcodeproj` and start developing.

The reason there is a Mac app inside the project is for testing purposes given that you cannot have frameworks linked with a Command Line application in xCode using Carthage. See [here](https://github.com/Carthage/Carthage/issues/287).

## Inspiration

* [Go's Martini](https://github.com/go-martini/martini)
* [Barista](https://github.com/SteveStreza/barista)
