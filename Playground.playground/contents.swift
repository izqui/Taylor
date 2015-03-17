//: Playground - noun: a place where people can play

import Cocoa
import XCPlayground
import Taylor

let server = Taylor.Server()

//server.addHandler(Taylor.Middleware.staticDirectory("/desktop", directory: "/Users/izqui/Desktop"))
server.addHandler(Taylor.Middleware.bodyParser())

server.get("/get") {
    (req, res) in
    
    let string = "<!DOCTYPE html><head><title>Hello</title></head><body><form method=\"POST\" action=\"/post\"><input type=\"text\" name=\"number\"/><input type=\"text\" name=\"name\"/><input type=\"submit\"/></form></body></html>"
    res.body = NSData(data: string.dataUsingEncoding(NSUTF8StringEncoding)!)
    res.headers["Content-type"] = "text/html"
    res.send()
}

server.get("/") {
    r, s in
    println(r.arguments)
    s.bodyString = "hellou"
    s.send()
}

server.post("/post") {
    req, res in
    
    if let n = req.body["number"], let i = n.toInt() {
    
        XCPCaptureValue("The number", i)
    }
    
    if let n = req.body["name"] {
        XCPCaptureValue("Name", n)
    }
    
    res.redirect(url: "/get")
}

server.startListening(port: 3000, forever: true)
XCPSetExecutionShouldContinueIndefinitely(continueIndefinitely: true)
