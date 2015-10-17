//
//  AppDelegate.swift
//  ARIEchoServer
//
//  Created by Helge Heß on 6/13/14.
//
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
  
  @IBOutlet var window        : NSWindow!
  @IBOutlet var logViewParent : NSScrollView!
  @IBOutlet var label         : NSTextField!
  
  var logView: NSTextView {
    // NSTextView doesn't work with weak?
    return logViewParent.contentView.documentView as! NSTextView
  }
  
  var echod : EchoServer?
  
  func applicationDidFinishLaunching(aNotification: NSNotification) {
    let port = 1337
    
    echod = EchoServer(port: port)
    echod!.appLog = { self.log($0) }
    echod!.start()
    
    label.stringValue =
      "Connect in e.g. Terminal via 'telnet 127.0.0.1 \(port)'"
  }

  func applicationWillTerminate(aNotification: NSNotification) {
    echod?.stop()
  }
  
  
  func log(string: String) {
    // log to shell
    print(string)
    
    // log to view. Careful, must run in main thread!
    dispatch_async(dispatch_get_main_queue()) {
      self.logView.appendString(string + "\n")
    }
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

