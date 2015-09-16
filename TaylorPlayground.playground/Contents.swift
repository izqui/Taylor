//: Playground - noun: a place where people can play

import Taylor
import Cocoa
import XCPlayground

XCPSetExecutionShouldContinueIndefinitely(true)

let server = Taylor.Server()

server.get("/") {
    req, res, cb in
    let file_path = NSBundle.mainBundle().pathForResource("index", ofType: "html")
    res.body = NSData(contentsOfFile: file_path!)
    cb(.Send(req, res))
}

server.get("/image") {
    req, res, cb in
    let file_path = NSBundle.mainBundle().pathForResource("meme", ofType: "jpg")
    res.body = NSData(contentsOfFile: file_path!)
    cb(.Send(req, res))
}

try! server.serveHTTP(port: 8080, forever: true)
