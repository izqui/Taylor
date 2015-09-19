//
//  Application.swift
//  Taylor
//
//  Created by Alejandro on 19/09/15.
//  Copyright © 2015 Jorge Izquierdo. All rights reserved.
//

import Foundation
import Taylor

class Application {
    
    let server = Taylor.Server()
    
    func configureRouter () {
        server.get("/") {
            req, res, cb in
            res.bodyString = "Hello, world!"
            cb(.Send(req, res))
        }
    }
    
    func runOnPort (port: Int) {
        self.configureRouter()
        do {
            print("Staring server on port: \(port)")
            try self.server.serveHTTP(port: port, forever: false) // Mac app keeps it up
        } catch let e {
            print("Server start failed \(e)")
        }
    }
    
    static let sharedInstance = Application()
    
}