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
    if let i = string.toInt() {
        port = i
    }
}


let taylor = Taylor(port: port)

taylor.get("/") {
    
    request, response in
    
    response.stringBody = "Hello Taylor!"
    
    response.headers["Content-Type"] = FileTypes.get("html")
    
    response.send()
    
    return nil
}

// Run forever
taylor.startListening(forever: true)



//"<h1>Hello</h1><p>What's your name?</p><form action=\"/form\" method=\"POST\"><input type=\"text\" name=\"name\"><input type=\"submit\"></form>"