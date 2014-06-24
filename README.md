Taylor
======

Taylor is a library which allows you to create web server applications in [Swift](https://developer.apple.com/swift/)

## Status

At this moment, Taylor only supports GET and POST HTTP requests.
It relies on `xcodebuild` to compile the binary, that's the reason of the existance of the `Taylor.xcodeproj` file

## Setup

You need to be running xCode 6 beta 2 or latest
```.sh
$ git clone http://github.com/izqui/Taylor taylor-server
$ cd taylor-server
# edit main.swift
$ ./run 3000
```

Open [localhost:3000](http://localhost:3000)

## Documentation

Coming soon

## Dependencies

Right now Taylor relies on an Objective-C library called [GCDAsyncSocket](https://github.com/robbiehanson/CocoaAsyncSocket/). I want to do my own implementation in Swift in the future.

## Inspiration

* [Go's Martini](https://github.com/go-martini/martini)
* [Barista](https://github.com/SteveStreza/barista)

