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
            s.bodyString = "<html><body><form method=\"POST\">Name: <input type=\"text\" name=\"name\"/><input type=\"submit\"/></form></body></html>"
            s.headers["Content-Type"] = "text/html"
            cb(.Send(r, s))
        }
               
        server.post("/", Middleware.bodyParser(), {
            r, s, cb in
            
            let name = r.body["name"] ?? "<unknown>"
            s.bodyString = "Hi \(name)"
            cb(.Send(r, s))
        })
       
        let port = 3002
        do {
            print("Staring server on port: \(port)")
            try server.serveHTTP(port: port, forever: false)
        } catch let e {
            print("Server start failed \(e)")
        }
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
}

