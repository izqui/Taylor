//
//  response.swift
//  TaylorTest
//
//  Created by Jorge Izquierdo on 19/06/14.
//  Copyright (c) 2014 Jorge Izquierdo. All rights reserved.
//

import Foundation

class Response {
    
    let _socket: GCDAsyncSocket
    
    
    var statusCode: Int = 200
    var statusLine: String = ""
    var headers: Dictionary<String, String> = Dictionary<String, String>()
    
    var body: NSData?
    var stringBody: NSString? {
    didSet {
        if !headers["Content-type"]{
            headers["Content-type"] = "text/plain"
        }
    }
    }
    
    let _protocol: String = "HTTP/1.1"
    var _codes = [
    200: "OK",
    201: "Created",
    202: "Accepted",
    
    300: "Multiple Choices",
    301: "Moved Permanently",
    302: "Found",
    303: "See other",
    
    400: "Bad Request",
    401: "Unauthorized",
    403: "Forbidden",
    404: "Not Found",
    
    500: "Internal Server Error",
    502: "Bad Gateway",
    503: "Service Unavailable"
    ]
    
    init(socket s: GCDAsyncSocket){
        
        _socket = s
    }
    
    func redirect() {
        
    }
    
    func send() {
        
        _socket.writeData(self.generateResponse(), withTimeout: 10, tag: 1)
    }
    
    func generateResponse() -> NSData {
        
        if let a = self._codes[self.statusCode]{
            
            self.statusLine = a
        }
        
        var bodyData: NSData = NSData()
        
        if body {
            bodyData = body!
        } else if stringBody {
            bodyData = NSData(data: stringBody!.dataUsingEncoding(NSUTF8StringEncoding))
        }
        
        if !headers["Content-length"] {
            headers["Content-length"] = String(bodyData.length)
        }
        
        var startLine = "\(self._protocol) \(String(self.statusCode)) \(self.statusLine)\n"
        
        var headersStr = ""
        for (k, v) in self.headers {
            
            headersStr += "\(k): \(v)\n"
        }
        
        headersStr += "\n"
        
        var data: NSMutableData = NSMutableData(data: String(startLine+headersStr).dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false))
        data.appendData(bodyData)
        
        return data as NSData
    }
}