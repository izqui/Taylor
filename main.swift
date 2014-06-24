//
//  main.swift
//  Taylor
//
//  Created by Jorge Izquierdo on 21/06/14.
//  Copyright (c) 2014 Jorge Izquierdo. All rights reserved.
//

import Foundation

//Check if port is being set from the command line
var port = 8000
if C_ARGC > 1 {
    
    var string = String.fromCString(C_ARGV[1])
    if let i = string.toInt() {
        port = i
    }
}

let taylor = Taylor(port: port)

taylor.use(Middleware.requestLogger())

//taylor.use(Middleware.staticDirectory("/public", directory: "files"))

//"Cool" way
taylor.get("/") {
    
    request, response in
    
    response.stringBody = "<h1>Hello World, GET</h1>"
    response.headers["Content-type"] = "text/html"
    response.send()
    
    return nil
}

taylor.post("/", Middleware.bodyParser()) {
    
    request, response in
    
    var str = "<h1>Hello World, POST</h1>\n"
    
    for (k, v) in request.body {
        
        str += "\(k) -> \(v)"
    }
    
    response.stringBody = str
    response.headers["Content-type"] = "text/html"
    response.send()
    
    return nil
}

//"What is going" on way
let router = Router()

let handler: TaylorHandler = {
    
    (request: Request, response: Response) in
    
    let parameterName = "world"
    if let name = request.arguments["name"] {
        
        response.stringBody = "Hello \(request.parameters[parameterName]!) \(name)"
    }
    else {
        
        response.stringBody = "Hello \(request.parameters[parameterName]!) stranger"
    }
    
    response.send()
    
    return nil
}

let route = Route(m: Request.HTTPMethod.GET, path: "/hello/:world", handlers: [handler])

router.addRoute(route)
taylor.router = router

// Run forever
taylor.startListening(forever: true)
