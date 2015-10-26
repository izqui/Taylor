//
//  AppDelegate.swift
//  ARIFetch
//
//  Created by Helge Hess on 6/13/14.
//
//

import Cocoa
import ARISockets

class AppDelegate: NSObject, NSApplicationDelegate {
                            
  @IBOutlet var window           : NSWindow!
  @IBOutlet var resultViewParent : NSScrollView!
  @IBOutlet var host             : NSTextField!
  @IBOutlet var port             : NSTextField!

  var resultView: NSTextView { // NSTextView doesn't work with weak?
    return resultViewParent.contentView.documentView as! NSTextView
  }

  func applicationDidFinishLaunching(aNotification: NSNotification) {
    fetch(nil)
  }

  func applicationWillTerminate(aNotification: NSNotification) {
    socket?.close()
  }
  
  
  var socket: ActiveSocketIPv4?

  @IBAction func fetch(sender: NSTextField?) {
    if let oldSock = socket {
      socket = nil
      oldSock.close()
      resultView.string = "" // clear results
    }
    
    socket = ActiveSocket<sockaddr_in>()
    print("Got socket: \(socket)")
    if socket == nil {
      return
    }
    
    let s = socket!
    
    s.onRead  { self.handleIncomingData($0, expectedCount: $1) }
    s.onClose { fd in print("Closing \(fd) ..."); }
    
    // connect
    
    let host = self.host.stringValue
    let port = Int(self.port.intValue)
    print("Connect \(host):\(port) ...")
    
    let ok = s.connect(sockaddr_in(address:host, port:port)) { s in
      print("connected \(s)")
      s.isNonBlocking = true
      
      s.write(
        "GET / HTTP/1.0\r\n" +
        "Content-Length: 0\r\n" +
        "X-Q-AlwaysRight: Yes, indeed\r\n" +
        "\r\n" +
        "\r\n"
      )
    }
    if !ok {
      print("connect failed \(s)")
      s.close()
      socket = nil
    }
  }

  func handleIncomingData<T>(socket: ActiveSocket<T>, expectedCount: Int) {
    repeat {
      let (count, block, errno) = socket.read()
      
      if count < 0 && errno == EWOULDBLOCK {
        break
      }
    
      print("got bytes: \(count)")
      
      if count < 1 {
        print("EOF \(socket)")
        socket.close()
        return
      }

      print("BLOCK: \(block)")
      // Sometimes fails in: Can't unwrap Optional.None (at bufsize==count?)
      // FIXME: I think I know why. It may happen if the block boundary is
      //        within a UTF-8 sequence?
      // The end of the block is 100,-30,-128,0
      let data = String.fromCString(block)! // ignore error, abort
      
      // log to view. Careful, must run in main thread!
      dispatch_async(dispatch_get_main_queue()) {
        self.resultView.appendString(data)
      }
    } while (true)
  }

}

extension NSTextView {
  
  func appendString(string: String) {
    if let ts = textStorage {
      let ls = NSAttributedString(string: string)
      ts.appendAttributedString(ls)
    }
    if let s = self.string {
      let charCount = (s as NSString).length
      self.scrollRangeToVisible(NSMakeRange(charCount, 0))
    }
    needsDisplay = true
  }
  
}
