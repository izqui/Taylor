//
//  main.swift
//  Taylor
//
//  Created by Jorge Izquierdo on 21/06/14.
//  Copyright (c) 2014 Jorge Izquierdo. All rights reserved.
//

import Foundation

//Check if port is being set from the command line
var port = 3003

if C_ARGC > 1 {

    var string = String.fromCString(C_ARGV[1])
    if let i = string?.toInt() {
        port = i
    }
}

let taylor = Server()

taylor.get("/", Middleware.requestLogger()) {
    
    request, response in
    
    response.stringBody = "Hello new batch!"

    response.headers["Content-Type"] = FileTypes.get("txt")
    
    response.send()
}

// Run forever
taylor.startListening(port: port, forever: true)
