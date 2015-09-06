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
        
        let server = Taylor.Server()
        
        server.get("/") {
            r, s, cb in
            s.bodyString = "Hello, world!"
            cb(.Send(r, s))
        }
               
        let port = 3001
        server.startListening(port: port, forever: false) {
            result in
            switch result {
            case .Success:
                print("Up and running on: \(port)")
            case .Error(let e):
                print("Server start failed \(e)")
            }
        }

    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

