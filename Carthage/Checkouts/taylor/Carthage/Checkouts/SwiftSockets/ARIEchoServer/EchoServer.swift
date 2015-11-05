//
//  EchoServer.swift
//  SwiftSockets
//
//  Created by Helge Hess on 6/13/14.
//  Copyright (c) 2014 Always Right Institute. All rights reserved.
//

import SwiftSockets

class EchoServer {

  let port         : Int
  var listenSocket : PassiveSocketIPv4?
  let lockQueue    = dispatch_queue_create("com.ari.socklock", nil)!
  var openSockets  = [FileDescriptor:ActiveSocket<sockaddr_in>](minimumCapacity: 8)
  var appLog       : ((String) -> Void)?
  
  init(port: Int) {
    self.port = port
  }
  
  func log(s: String) {
    if let lcb = appLog {
      lcb(s)
    }
    else {
      print(s)
    }
  }
  
  func start() {
    listenSocket = PassiveSocketIPv4(address: sockaddr_in(port: port))
    if listenSocket == nil || !listenSocket! { // neat, eh? ;-)
      log("ERROR: could not create socket ...")
      return
    }
    
    log("Listen socket \(listenSocket)")
    
    let queue = dispatch_get_global_queue(0, 0)
    
    // Note: capturing self here
    listenSocket!.listen(queue, backlog: 5) { newSock in
      
      self.log("got new socket: \(newSock) nio=\(newSock.isNonBlocking)")
      newSock.isNonBlocking = true
      
      dispatch_async(self.lockQueue) {
        // Note: we need to keep the socket around!!
        self.openSockets[newSock.fd] = newSock
      }
      
      self.sendWelcome(newSock)
      
      newSock.onRead  { self.handleIncomingData($0, expectedCount: $1) }
             .onClose { ( fd: FileDescriptor ) -> Void in
        // we need to consume the return value to give peace to the closure
        dispatch_async(self.lockQueue) { [unowned self] in
          _ = self.openSockets.removeValueForKey(fd)
        }
      }
      
      
    }
    
    log("Started running listen socket \(listenSocket)")
  }
  
  func stop() {
    listenSocket?.close()
    listenSocket = nil
  }
  
  func sendWelcome<T: OutputStreamType>(var sock: T) {
    // Hm, how to use print(), this doesn't work for me:
    //   print(s, target: sock)
    // (just writes the socket as a value, likely a tuple)
    
    sock.write("\r\n" +
       "  /----------------------------------------------------\\\r\n" +
       "  |     Welcome to the Always Right Institute!         |\r\n"  +
       "  |    I am an echo server with a zlight twist.        |\r\n"  +
       "  | Just type something and I'll shout it back at you. |\r\n"  +
      "  \\----------------------------------------------------/\r\n"  +
      "\r\nTalk to me Dave!\r\n" +
      "> "
    )
  }
  
  func handleIncomingData<T>(socket: ActiveSocket<T>, expectedCount: Int) {
    // remove from openSockets if all has been read
    repeat {
      // FIXME: This currently continues to read garbage if I just close the
      //        Terminal which hosts telnet. Even with sigpipe off.
      let (count, block, errno) = socket.read()
      
      if count < 0 && errno == EWOULDBLOCK {
        break
      }
      
      if count < 1 {
        log("EOF \(socket) (err=\(errno))")
        socket.close()
        return
      }
      
      logReceivedBlock(block, length: count)
      
      // maps the whole block. asyncWrite does not accept slices,
      // can we add this?
      // (should adopt sth like IndexedCollection<T>?)
      /* ptr has no map ;-) FIXME: add an extension 'mapWithCount'?
      let mblock = block.map({ $0 == 83 ? 90 : ($0 == 115 ? 122 : $0) })
      */
      var mblock = [CChar](count: count + 1, repeatedValue: 42)
      for var i = 0; i < count; i++ {
        let c = block[i]
        mblock[i] = c == 83 ? 90 : (c == 115 ? 122 : c)
      }
      mblock[count] = 0
      
      socket.asyncWrite(mblock, length: count)
    } while (true)
    
    socket.write("> ")
  }

  func logReceivedBlock(block: UnsafePointer<CChar>, length: Int) {
    let k = String.fromCString(block)
    var s = k ?? "Could not process result block \(block) length \(length)"
    
    // Hu, now this is funny. In b5 \r\n is one Character (but 2 unicodeScalars)
    if s.hasSuffix("\r\n") {
      s = s[s.startIndex..<s.endIndex.predecessor()]
    }
    
    log("read string: \(s)")
  }
  
  final let alwaysRight = "Yes, indeed!"
}
