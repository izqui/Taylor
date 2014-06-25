//
//  main.swift
//  FileServer
//
//  Created by Jorge Izquierdo on 25/06/14.
//  Copyright (c) 2014 Jorge Izquierdo. All rights reserved.
//

import Foundation

var port = 8000
if C_ARGC > 1 {
    
    var string = String.fromCString(C_ARGV[1])
    if let i = string.toInt() {
        port = i
    }
}

let taylor = Taylor(port: port)

taylor.use(Middleware.staticDirectory("/", directory: "~/Dropbox/HackerSchool/Taylor/examples/FileServer/static"))

// Run forever
taylor.startListening(forever: true)


