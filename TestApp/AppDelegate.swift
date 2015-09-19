//
//  AppDelegate.swift
//  TestApp
//
//  Created by Jorge Izquierdo on 9/6/15.
//  Copyright © 2015 Jorge Izquierdo. All rights reserved.
//

import Cocoa
import Taylor

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        Application.sharedInstance.runOnPort(Configuration.port)
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
}

