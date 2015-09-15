//: Playground - noun: a place where people can play

import Taylor
import XCPlayground

XCPSetExecutionShouldContinueIndefinitely()

let server = Taylor.Server()

server.get("/") {
    r, s, cb in
    
    s.bodyString = "hey"
    cb(.Send(r, s))
}

try! server.serveHTTP(port: 8080, forever: true)
