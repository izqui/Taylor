//
//  ActiveSocket.swift
//  ARISockets
//
//  Created by Helge Hess on 6/11/14.
//  Copyright (c) 2014 Always Right Institute. All rights reserved.
//

import Darwin
import Dispatch

public typealias ActiveSocketIPv4 = ActiveSocket<sockaddr_in>

/**
 * Represents an active STREAM socket based on the standard Unix sockets
 * library.
 *
 * An active socket can be either a socket gained by calling accept on a
 * passive socket or by explicitly connecting one to an address (a client
 * socket).
 * Therefore an active socket has two addresses, the local and the remote one.
 *
 * There are three methods to perform a close, this is rooted in the fact that
 * a socket actually is full-duplex, it provides a send and a receive channel.
 * The stream-mode is updated according to what channels are open/closed. 
 * Initially the socket is full-duplex and you cannot reopen a channel that was
 * shutdown. If you have shutdown both channels the socket can be considered
 * closed.
 *
 * Sample:
 *   let socket = ActiveSocket<sockaddr_in>()
 *     .onRead {
 *       let (count, block) = $0.read()
 *       if count < 1 {
 *         print("EOF, or great error handling.")
 *         return
 *       }
 *       print("Answer to ring,ring is: \(count) bytes: \(block)")
 *     }
 *   socket.connect(sockaddr_in(address:"127.0.0.1", port: 80))
 *   socket.write("Ring, ring!\r\n")
 */
public class ActiveSocket<T: SocketAddress>: Socket<T> {
  
  public var remoteAddress  : T?                 = nil
  public var queue          : dispatch_queue_t?  = nil
  
  var readSource     : dispatch_source_t? = nil
  var sendCount      : Int                = 0
  var closeRequested : Bool               = false
  var didCloseRead   : Bool               = false
  var readCB         : ((ActiveSocket, Int) -> Void)? = nil
  
  // let the socket own the read buffer, what is the best buffer type?
  //var readBuffer     : [CChar] =  [CChar](count: 4096 + 2, repeatedValue: 42)
  var readBufferPtr  = UnsafeMutablePointer<CChar>.alloc(4096 + 2)
  var readBufferSize : Int = 4096 { // available space, a bit more for '\0'
    didSet {
      if readBufferSize != oldValue {
        readBufferPtr.dealloc(oldValue + 2)
        readBufferPtr = UnsafeMutablePointer<CChar>.alloc(readBufferSize + 2)
      }
    }
  }
  
  
  public var isConnected : Bool {
    guard isValid else { return false }
    return remoteAddress != nil
  }
  
  
  /* init */
  
  override public init(fd: FileDescriptor) {
    // required, otherwise the convenience one fails to compile
    super.init(fd: fd)
  }

  /* Still crashes Swift 2b3 compiler (when the method below is removed)
  public convenience init?() {
    self.init(type: SOCK_STREAM) // assumption is that we inherit this
                                 // though it should work right away?
  }
  */
  public convenience init?(type: Int32 = SOCK_STREAM) {
    // TODO: copy of Socket.init(type:), but required to compile. Not sure
    // what's going on with init inheritance here. Do I *have to* read the
    // manual???
    let   lfd  = socket(T.domain, type, 0)
    guard lfd != -1 else { return nil }
    
    self.init(fd: FileDescriptor(lfd))
  }
  
  public convenience init
    (fd: FileDescriptor, remoteAddress: T?, queue: dispatch_queue_t? = nil)
  {
    self.init(fd: fd)
    
    self.remoteAddress  = remoteAddress
    self.queue          = queue
    
    isSigPipeDisabled = fd.isValid // hm, hm?
  }
  deinit {
    readBufferPtr.dealloc(readBufferSize + 2)
  }
  
  
  /* close */
  
  override public func close() {
    if debugClose { debugPrint("closing socket \(self)") }
    
    guard isValid else { // already closed
      if debugClose { debugPrint("   already closed.") }
      return
    }
    
    // always shutdown receiving end, should call shutdown()
    // TBD: not sure whether we have a locking issue here, can read&write
    //      occur on different threads in GCD?
    if !didCloseRead {
      if debugClose { debugPrint("   stopping events ...") }
      stopEventHandler()
      // Seen this crash - if close() is called from within the readCB?
      readCB = nil // break potential cycles
      if debugClose { debugPrint("   shutdown read channel ...") }
      Darwin.shutdown(fd.fd, SHUT_RD);
      
      didCloseRead = true
    }
    
    if sendCount > 0 {
      if debugClose { debugPrint("   sends pending, requesting close ...") }
      closeRequested = true
      return
    }
    
    queue = nil // explicitly release, might be a good idea ;-)
    
    if debugClose { debugPrint("   super close.") }
    super.close()
  }
  
  
  /* connect */
  
  public func connect(address: T, onConnect: () -> Void) -> Bool {
    // FIXME: make connect() asynchronous via GCD
    
    guard !isConnected else {
      // TBD: could be tolerant if addresses match
      print("Socket is already connected \(self)")
      return false
    }
    guard fd.isValid else { return false }
    
    // Note: must be 'var' for ptr stuff, can't use let
    var addr = address
    
    let lfd = fd.fd
    let rc = withUnsafePointer(&addr) { ptr -> Int32 in
      let bptr = UnsafePointer<sockaddr>(ptr) // cast
      return Darwin.connect(lfd, bptr, socklen_t(addr.len)) //only returns block
    }
    
    guard rc == 0 else {
      print("Could not connect \(self) to \(addr)")
      return false
    }
    
    remoteAddress = addr
    onConnect()
    
    return true
  }
  
  /* read */
  
  public func onRead(cb: ((ActiveSocket, Int) -> Void)?) -> Self {
    let hadCB    = readCB != nil
    let hasNewCB = cb != nil
    
    if !hasNewCB && hadCB {
      stopEventHandler()
    }
    
    readCB = cb
    
    if hasNewCB && !hadCB {
      startEventHandler()
    }
    
    return self
  }
  
  // This doesn't work, can't override a stored property
  // Leaving this feature alone for now, doesn't have real-world importance
  // @lazy override var boundAddress: T? = getRawAddress()
  
  
  /* description */
  
  override func descriptionAttributes() -> String {
    // must be in main class, override not available in extensions
    var s = super.descriptionAttributes()
    if remoteAddress != nil {
      s += " remote=\(remoteAddress!)"
    }
    return s
  }
}


extension ActiveSocket : OutputStreamType { // writing
  
  // no let in extensions: let debugAsyncWrites = false
  var debugAsyncWrites : Bool { return false }
  
  public var canWrite : Bool {
    guard isValid else {
      assert(isValid, "Socket closed, can't do async writes anymore")
      return false
    }
    guard !closeRequested else {
      assert(!closeRequested, "Socket is being shutdown already!")
      return false
    }
    return true
  }
  
  public func write(data: dispatch_data_t) {
    sendCount++
    if debugAsyncWrites { debugPrint("async send[\(data)]") }
    
    // in here we capture self, which I think is right.
    dispatch_write(fd.fd, data, queue!) {
      asyncData, error in
      
      if self.debugAsyncWrites {
        debugPrint("did send[\(self.sendCount)] data \(data) error \(error)")
      }
      
      self.sendCount = self.sendCount - 1 // -- fails?
      
      if self.sendCount == 0 && self.closeRequested {
        if self.debugAsyncWrites { debugPrint("closing after async write ...") }
        self.close()
        self.closeRequested = false
      }
    }
    
  }
  
  public func asyncWrite<T>(buffer: [T]) -> Bool {
    // While [T] seems to convert to ConstUnsafePointer<T>, this method
    // has the added benefit of being able to derive the buffer length
    guard canWrite else { return false }
    
    let writelen = buffer.count
    let bufsize  = writelen * sizeof(T)
    guard bufsize > 0 else { // Nothing to write ..
      return true
    }
    
    if queue == nil {
      debugPrint("No queue set, using main queue")
      queue = dispatch_get_main_queue()
    }
    
    // the default destructor is supposed to copy the data. Not good, but
    // handling ownership is going to be messy
    guard let asyncData = dispatch_data_create(buffer,bufsize, queue,nil) else {
      return false
    }
    
    write(asyncData)
    return true
  }
  
  public func asyncWrite<T>(buffer: UnsafePointer<T>, length:Int) -> Bool {
    // FIXME: can we remove this dupe of the [T] version?
    guard canWrite else { return false }
    
    let writelen = length
    let bufsize  = writelen * sizeof(T)
    guard bufsize > 0 else { // Nothing to write ..
      return true
    }
    
    if queue == nil {
      debugPrint("No queue set, using main queue")
      queue = dispatch_get_main_queue()
    }
    
    // the default destructor is supposed to copy the data. Not good, but
    // handling ownership is going to be messy
    guard let asyncData = dispatch_data_create(buffer,bufsize, queue,nil) else {
      return false
    }
    
    write(asyncData)
    return true
  }
  
  public func send<T>(buffer: [T], length: Int? = nil) -> Int {
    // var writeCount : Int = 0
    let bufsize    = length ?? buffer.count
    
    // this is funky
    let ( _, writeCount ) = fd.write(buffer, count: bufsize)

    return writeCount
  }
  
  public func write(string: String) {
    string.withCString { (cstr: UnsafePointer<Int8>) -> Void in
      let len = Int(strlen(cstr))
      if len > 0 {
        self.asyncWrite(cstr, length: len)
      }
    }
  }
  
}


extension ActiveSocket { // Reading
  
  // Note: Swift doesn't allow the readBuffer in here.
  
  public func read() -> ( size: Int, block: UnsafePointer<CChar>, error: Int32){
    let bptr = UnsafePointer<CChar>(readBufferPtr)
    
    guard fd.isValid else {
      print("Called read() on closed socket \(self)")
      readBufferPtr[0] = 0
      return ( -42, bptr, EBADF )
    }
    
    var readCount: Int = 0
    let bufsize = readBufferSize
    
    // FIXME: If I just close the Terminal which hosts telnet this continues
    //        to read garbage from the server. Even with SIGPIPE off.
    readCount = Darwin.read(fd.fd, readBufferPtr, bufsize)
    guard readCount >= 0 else {
      readBufferPtr[0] = 0
      return ( readCount, bptr, errno )
    }
    
    readBufferPtr[readCount] = 0 // convenience
    return ( readCount, bptr, 0 )
  }
  
  
  /* setup read event handler */
  
  func stopEventHandler() {
    if readSource != nil {
      dispatch_source_cancel(readSource!)
      readSource = nil // abort()s if source is not resumed ...
    }
  }
  
  func startEventHandler() -> Bool {
    guard readSource == nil else {
      print("Read source already setup?")
      return true // already setup
    }
    
    /* do we have a queue? */
    
    if queue == nil {
      debugPrint("No queue set, using main queue")
      queue = dispatch_get_main_queue()
    }
    
    /* setup GCD dispatch source */
    
    readSource = dispatch_source_create(
      DISPATCH_SOURCE_TYPE_READ,
      UInt(fd.fd), // is this going to bite us?
      0,
      queue
    )
    guard readSource != nil else {
      print("Could not create dispatch source for socket \(self)")
      return false
    }
    
    // TBD: do we create a retain cycle here (self vs self.readSource)
    readSource!.onEvent { [unowned self]
      _, readCount in
      if let cb = self.readCB {
        cb(self, Int(readCount))
      }
    }
    
    /* actually start listening ... */
    dispatch_resume(readSource!)
    
    return true
  }
  
}

extension ActiveSocket { // ioctl
  
  var numberOfBytesAvailableForReading : Int? {
    return fd.numberOfBytesAvailableForReading
  }
  
}
