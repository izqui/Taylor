SwiftSockets
============

A simple GCD based socket library for Swift.

SwiftSockets is kind of a demo on how to integrate Swift with raw C APIs. More
for stealing Swift coding ideas than for actually using the code in a real
world project. In most real world Swift apps you have access to Cocoa, use it.

It also comes with a great Echo daemon as a demo, it's always there if you need
a chat.

**Note**: This is my first [Swift](https://developer.apple.com/swift/) project.
Any suggestions on how to improve the code are welcome. I expect lots and lots
:-)

###Targets

Updated for Swift 0.2 beta 6 (aka Xcode 7b6).

The project includes three targets:
- ARISockets
- ARIEchoServer
- ARIFetch

I suggest you start out looking at the ARIEchoServer.

####ARISockets

A framework containing the socket classes and relevant extensions. It takes a
bit of inspiration from the [SOPE](http://sope.opengroupware.org) NGStreams
library.

Server Sample:
```swift
let socket = PassiveSocket<sockaddr_in>(address: sockaddr_in(port: 4242))!
  .listen(dispatch_get_global_queue(0, 0), backlog: 5) {
    print("Wait, someone is attempting to talk to me!")
    $0.close()
    print("All good, go ahead!")
  }
```

Client Sample:
```swift
let socket = ActiveSocket<sockaddr_in>()!
  .onRead {
    let (count, block, errno) = $0.read()
    guard count > 0 else {
      print("EOF, or great error handling \(errno).")
      return
    }
    print("Answer to ring,ring is: \(count) bytes: \(block)")
  }
  .connect("127.0.0.1:80") {
    socket.write("Ring, ring!\r\n")
  }
```

####ARIEchoServer

Great echo server. This is actually a Cocoa app. Compile it, run it, then
connect to it in the Terminal.app via ```telnet 1337```.

![](http://i.imgur.com/874ovtE.png)

####ARIFetch

Connects a socket to some end point, sends an HTTP/1.0 GET request with some
awesome headers, then shows the results the server sends. Cocoa app.

Why HTTP/1.0? Avoids redirects on www.apple.com :-)

![](http://i.imgur.com/nRhADxg.png)


###Goals

- [x] Max line length: 80 characters
- [ ] Great error handling
  - [x] PS style great error handling
  - [x] print() error handling
  - [ ] Swift 2 try/throw/catch
    - [ ] Real error handling
- [x] Twisted (no blocking reads or writes)
  - [x] Async reads and writes
    - [x] Never block on reads
    - [x] Never block on listen
  - [ ] Async connect()
- [ ] Support all types of Unix sockets & addresses
  - [x] IPv4
  - [ ] IPv6 (I guess this should work too)
  - [ ] Unix domain sockets
  - [ ] Datagram sockets
- [x] No NS'ism
- [ ] Use as many language features Swift provides
  - [x] Generics
    - [x] Generic function
    - [x] typealias
  - [x] Closures
    - [x] weak self
    - [x] trailing closures
    - [x] implicit parameters
  - [ ] Unowned
  - [x] Extensions on structs
  - [x] Extensions to organize classes
  - [x] Protocols on structs
  - [ ] Swift 2 protocol extensions
  - [x] Tuples, with labels
  - [x] Trailing closures
  - [ ] @Lazy
  - [x] Pure Swift weak delegates via @class
  - [x] Optionals
  - [x] Convenience initializers
  - [x] Failable initializers
  - [x] Class variables on structs
  - [x] CConstPointer, CConstVoidPointer
    - [x] withCString {}
  - [x] UnsafePointer
  - [x] sizeof()
  - [x] Standard Protocols
    - [x] Printable
    - [x] BooleanType (aka LogicValue)
    - [x] OutputStreamType
    - [x] Equatable
      - [ ] Equatable on Enums with Associated Values
    - [x] Hashable
    - [x] SequenceType (GeneratorOf<T>)
    - [x] Literal Convertibles
      - [x] StringLiteralConvertible
      - [ ] IntegerLiteralConvertible
  - [x] Left shift AND right shift
  - [ ] Enums on steroids
  - [ ] Dynamic type system, reflection
  - [x] Operator overloading
  - [ ] UCS-4 identifiers (🐔🐔🐔)
  - [ ] ~~RTF source code with images and code sections in different fonts~~
  - [ ] Nested classes/types
  - [ ] Patterns
    - [x] Use wildcard pattern to ignore value
  - [x] Literal Convertibles
  - [ ] @autoclosure
  - [ ] unsafeBitCast (was reinterpretCast)
  - [x] final
  - [x] Nil coalescing operator
  - [ ] dynamic
  - [ ] Swift 2
    - [ ] availability
    - [x] guard
    - [x] defer
    - [ ] C function pointers
    - [x] debugPrint
    - [ ] lowercaseString

###Why?!

This is an experiment to get acquainted with Swift. To check whether something
real can be implemented in 'pure' Swift. Meaning, without using any Objective-C
Cocoa classes (no NS'ism).
Or in other words: Can you use Swift without writing all the 'real' code in
wrapped Objective-C? :-)

###Contact

[@helje5](http://twitter.com/helje5) | helge@alwaysrightinstitute.com

![](http://www.alwaysrightinstitute.com/ARI.png)
