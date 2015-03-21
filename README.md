Taylor
======

Disclaimer: It is a work in progress, it may break. Use it at your own risk.

Taylor is a library which allows you to create web server applications in [Swift](https://developer.apple.com/swift/)

## Status

At this moment, Taylor only supports GET, POST and PUT HTTP requests.
Better documentation is on the way.

## Demo

You can use Taylor from the command line using [Rome](https://github.com/neonichu/Rome) or [Carthage](https://github.com/Carthage/Carthage) as dependency managers, or just compiling the Framework within the `.xcworkspace`

Credits to [Ayaka Nonaka](https://twitter.com/ayanonagon)'s [Swift Summit](http://swiftsummit.com) talk for sharing this method for doing Scripting in Swift

```.swift
#!/usr/bin/env xcrun swift -F Rome

import Taylor

let server = Taylor.Server()
server.addPostRequestHandler(Middleware.requestLogger(println))

server.get("/") {
    request, response, callback in

    response.bodyString  = "Hello World!"

    callback(.Send(request, response))
}

server.startListening(port: 4000, forever: true) {
    result in
    switch result {
    case .Success:
        println("Up and running")
    case .Error(let e):
        println("Server start failed \(e)")
    }
}
```

```.sh
chmod +x server.swift
./server.swift
```

## Dependencies

Right now Taylor relies on an Objective-C library called [CocoaAsyncSocket](https://github.com/robbiehanson/CocoaAsyncSocket/).

## Inspiration

* [Go's Martini](https://github.com/go-martini/martini)
* [Barista](https://github.com/SteveStreza/barista)

