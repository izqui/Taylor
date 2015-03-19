//: Playground - noun: a place where people can play

import Cocoa
import XCPlayground
import Taylor

let server = Taylor.Server()

server.addHandler(Middleware.staticDirectory("/talk", bundle: NSBundle.mainBundle()))
server.get("/hi") {
    req, res, cb in
    res.bodyString = "Hello my friend!"
    cb(.Send(req, res))
}

server.addPostRequestHandler(Middleware.requestLogger({XCPCaptureValue("Requests", $0)}))

let port = 3001
server.startListening(port: port, forever: true) {
    result in
    switch result {
    case .Success:
        println("Up and running on \(NSHost.currentHost().addresses[1]):\(port)")
    case .Error(let e):
        println("Server start failed \(e)")
    }
}

XCPSetExecutionShouldContinueIndefinitely(continueIndefinitely: true)
/*
server.get("/post") {
req, res, cb in

res.setFile(NSBundle.mainBundle().URLForResource("test", withExtension: "html"))
cb(.Send(req, res))
}

server.post("/post", Middleware.bodyParser(), {
req, res, cb in

if let n = req.body["number"], let i = n.toInt() {

XCPCaptureValue("Number", i)
}

if let n = req.body["name"] {
XCPCaptureValue("Name", n)
}

res.redirect(url: "/")
cb(.Send(req, res))
})

*/
