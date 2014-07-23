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

let taylor: Taylor.Server = Taylor.NewServer()

taylor.addHandler(Taylor.Middleware.requestLogger())

taylor.get("/") {
    
    req, res in
    
    res.bodyString = "Hello world"
    
    res.send()
}

taylor.get("/form/:name") {
    
    req, res in
    
    var name = req.parameters["name"]!
    res.bodyString = "<h1>Hello \(name) <form method=\"POST\"><p>Your age:</p> <input type=\"text\" name=\"age\"><input type=\"submit\"></form>"
    res.headers["Content-Type"] = Taylor.FileTypes.get("html")
    
    res.send()
}

taylor.post("/form/:name", Taylor.Middleware.bodyParser()) {
    
    req, res in
    
    var name = req.parameters["name"]!
    var age = "unknown"
    
    if let a = req.body["age"]{
        age = a
    }
    
    res.bodyString = "\(name)'s age is \(age)"
    res.send()
}

// Run forever
taylor.startListening(port: port, forever: true)
