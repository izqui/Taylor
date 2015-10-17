//
//  ARISocket.swift
//  ARISockets
//
//  Created by Helge Heß on 6/9/14.
//  Copyright (c) 2014 Always Right Institute. All rights reserved.
//

import Darwin
import Dispatch

/**
 * Simple Socket classes for Swift.
 *
 * PassiveSockets are 'listening' sockets, ActiveSockets are open connections.
 */
public class Socket<T: SocketAddress> {
  
  public var fd           : FileDescriptor = nil
  public var boundAddress : T?      = nil
  public var isValid      : Bool { return fd.isValid }
  public var isBound      : Bool { return boundAddress != nil }
  
  var closeCB  : ((FileDescriptor) -> Void)? = nil
  var closedFD : FileDescriptor? = nil // for delayed callback
  
  
  /* initializer / deinitializer */
  
  public init(fd: FileDescriptor) {
    self.fd = fd
  }
  deinit {
    close() // TBD: is this OK/safe?
  }
  
  public convenience init?(type: Int32 = SOCK_STREAM) {
    let   lfd  = socket(T.domain, type, 0)
    guard lfd != -1 else { return nil }
    
    self.init(fd: FileDescriptor(lfd))
  }
  
  
  /* explicitly close the socket */
  
  let debugClose = false
  
  public func close() {
    if fd.isValid {
      closedFD = fd
      if debugClose { print("Closing socket \(closedFD) for good ...") }
      fd.close()
      fd       = nil
      
      if let cb = closeCB {
        // can be used to unregister socket etc when the socket is really closed
        if debugClose { print("  let closeCB \(closedFD) know ...") }
        cb(closedFD!)
        closeCB = nil // break potential cycles
      }
      if debugClose { print("done closing \(closedFD)") }
    }
    else if debugClose {
      print("socket \(closedFD) already closed.")
    }
    
    boundAddress = nil
  }
  
  public func onClose(cb: ((FileDescriptor) -> Void)?) -> Self {
    if let fd = closedFD { // socket got closed before event-handler attached
      if let lcb = cb {
        lcb(fd)
      }
      else {
        closeCB = nil
      }
    }
    else {
      closeCB = cb
    }
    return self
  }
  
  
  /* bind the socket. */
  
  public func bind(address: T) -> Bool {
    guard fd.isValid else { return false }
    
    guard !isBound else {
      print("Socket is already bound!")
      return false
    }
    
    // Note: must be 'var' for ptr stuff, can't use let
    var addr = address

    let rc = withUnsafePointer(&addr) { ptr -> Int32 in
      let bptr = UnsafePointer<sockaddr>(ptr) // cast
      return Darwin.bind(fd.fd, bptr, socklen_t(addr.len))
    }
    
    if rc == 0 {
      // Generics TBD: cannot check for isWildcardPort, always grab the name
      boundAddress = getsockname()
      /* if it was a wildcard port bind, get the address */
      // boundAddress = addr.isWildcardPort ? getsockname() : addr
    }
    
    return rc == 0 ? true : false
  }
  
  public func getsockname() -> T? {
    return _getaname(Darwin.getsockname);
  }
  public func getpeername() -> T? {
    return _getaname(Darwin.getpeername);
  }
  
  typealias GetNameFN = ( Int32, UnsafeMutablePointer<sockaddr>,
                          UnsafeMutablePointer<socklen_t>) -> Int32
  func _getaname(nfn: GetNameFN) -> T? {
    guard fd.isValid else { return nil }
    
    // FIXME: tried to encapsulate this in a sockaddrbuf which does all the
    //        ptr handling, but it ain't work (autoreleasepool issue?)
    var baddr    = T()
    var baddrlen = socklen_t(baddr.len)
    
    // Note: we are not interested in the length here, would be relevant
    //       for AF_UNIX sockets
    let rc = withUnsafeMutablePointer(&baddr) {
      ptr -> Int32 in
      let bptr = UnsafeMutablePointer<sockaddr>(ptr) // cast
      return nfn(fd.fd, bptr, &baddrlen)
    }
    
    guard rc == 0 else {
      print("Could not get sockname? \(rc)")
      return nil
    }
    
    // print("PORT: \(baddr.sin_port)")
    return baddr
  }
  
  
  /* description */
  
  // must live in the main-class as 'declarations in extensions cannot be
  // overridden yet' (Same in Swift 2.0)
  func descriptionAttributes() -> String {
    var s = fd.isValid
      ? " fd=\(fd.fd)"
      : (closedFD != nil ? " closed[\(closedFD)]" :" not-open")
    if boundAddress != nil {
      s += " \(boundAddress!)"
    }
    return s
  }
  
}


extension Socket { // Socket Flags
  
  public var flags : Int32? {
    get { return fd.flags      }
    set { fd.flags = newValue! }
  }
  
  public var isNonBlocking : Bool {
    get { return fd.isNonBlocking }
    set { fd.isNonBlocking = newValue }
  }
  
}

extension Socket { // Socket Options

  public var reuseAddress: Bool {
    get { return getSocketOption(SO_REUSEADDR) }
    set { setSocketOption(SO_REUSEADDR, value: newValue) }
  }
  public var isSigPipeDisabled: Bool {
    get { return getSocketOption(SO_NOSIGPIPE) }
    set { setSocketOption(SO_NOSIGPIPE, value: newValue) }
  }
  public var keepAlive: Bool {
    get { return getSocketOption(SO_KEEPALIVE) }
    set { setSocketOption(SO_KEEPALIVE, value: newValue) }
  }
  public var dontRoute: Bool {
    get { return getSocketOption(SO_DONTROUTE) }
    set { setSocketOption(SO_DONTROUTE, value: newValue) }
  }
  public var socketDebug: Bool {
    get { return getSocketOption(SO_DEBUG) }
    set { setSocketOption(SO_DEBUG, value: newValue) }
  }
  
  public var sendBufferSize: Int32 {
    get { return getSocketOption(SO_SNDBUF) ?? -42    }
    set { setSocketOption(SO_SNDBUF, value: newValue) }
  }
  public var receiveBufferSize: Int32 {
    get { return getSocketOption(SO_RCVBUF) ?? -42    }
    set { setSocketOption(SO_RCVBUF, value: newValue) }
  }
  public var socketError: Int32 {
    return getSocketOption(SO_ERROR) ?? -42
  }
  
  /* socket options (TBD: would we use subscripts for such?) */
  
  
  public func setSocketOption(option: Int32, value: Int32) -> Bool {
    if !isValid {
      return false
    }
    
    var buf = value
    let rc  = setsockopt(fd.fd, SOL_SOCKET, option,
                         &buf, socklen_t(sizeof(Int32)))
    
    if rc != 0 { // ps: Great Error Handling
      print("Could not set option \(option) on socket \(self)")
    }
    return rc == 0
  }
  
  // TBD: Can't overload optionals in a useful way?
  // func getSocketOption(option: Int32) -> Int32
  public func getSocketOption(option: Int32) -> Int32? {
    if !isValid {
      return nil
    }
    
    var buf    = Int32(0)
    var buflen = socklen_t(sizeof(Int32))
    
    let rc = getsockopt(fd.fd, SOL_SOCKET, option, &buf, &buflen)
    if rc != 0 { // ps: Great Error Handling
      print("Could not get option \(option) from socket \(self)")
      return nil
    }
    return buf
  }
  
  public func setSocketOption(option: Int32, value: Bool) -> Bool {
    return setSocketOption(option, value: value ? 1 : 0)
  }
  public func getSocketOption(option: Int32) -> Bool {
    let v: Int32? = getSocketOption(option)
    return v != nil ? (v! == 0 ? false : true) : false
  }
  
}


extension Socket { // poll()
  
  public var isDataAvailable: Bool { return fd.isDataAvailable }
  
  public func pollFlag(flag: Int32) -> Bool { return fd.pollFlag(flag) }
  
  public func poll(events: Int32, timeout: UInt? = 0) -> Int32? {
    return fd.poll(events, timeout: timeout)
  }
  
}


extension Socket: CustomStringConvertible {
  
  public var description : String {
    return "<Socket:" + descriptionAttributes() + ">"
  }
  
}


extension Socket: BooleanType { // TBD: Swift doesn't want us to do this
  
  public var boolValue : Bool {
    return isValid
  }
  
}
