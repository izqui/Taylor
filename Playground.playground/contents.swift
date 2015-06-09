//: Playground - noun: a place where people can play

import Cocoa
import XCPlayground


import Taylor

let server = Taylor.Server()

server.addHandler(Middleware.staticDirectory("/talk", bundle: NSBundle.mainBundle()))

server.addPostRequestHandler(Middleware.requestLogger({XCPCaptureValue("Requests", value: $0)}))

server.get("/") {
    r, s, cb in
    s.bodyString = "Hello, world!"
    cb(.Send(r, s))
}

server.get("/image") {
    req, res, cb in
    res.setFile(NSBundle.mainBundle().URLForResource("test", withExtension: "html"))
    cb(.Send(req, res))
}
server.post("/image", Taylor.Middleware.bodyParser(), {
    req, res, cb in

    if let f = req.body["filter"], let i = Int(f) {
        
        res.body = filteredImage(filters[(i<filters.count ? i : 0)])
        res.headers["Content-type"] = "image/jpg"
        
    } else {
        res.statusCode = 404
        res.bodyString = "Filter not found"
    }
    cb(.Send(req, res))
})


let port = 3001
server.startListening(port: port, forever: true) {
    result in
    switch result {
    case .Success:
        print("Up and running on \(getIPAddress()):\(port)")
    case .Error(let e):
        print("Server start failed \(e)")
    }
}

XCPSetExecutionShouldContinueIndefinitely(true)




/*
*/
