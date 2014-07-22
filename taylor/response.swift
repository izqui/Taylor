//
//  response.swift
//  TaylorTest
//
//  Created by Jorge Izquierdo on 19/06/14.
//  Copyright (c) 2014 Jorge Izquierdo. All rights reserved.
//

import Foundation

public class Response: ResponseProtocol {
    
    private let socket: GCDAsyncSocket?
    private var statusLine: String = ""
    
    public var statusCode: Int = 200
    public var headers: Dictionary<String, String> = Dictionary<String, String>()
    public var body: NSData?
    
    public var sent: Bool = false
    
    var stringBody: NSString? {
    didSet {
        if !headers["Content-Type"]{
            headers["Content-Type"] = FileTypes.get("txt")
        }
    }
    }
    
    private let http_protocol: String = "HTTP/1.1"
    internal var codes = [
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
    
    convenience init(){
        
        self.init(socket: nil)
    }

    
    init(socket s: GCDAsyncSocket?){
        
        socket = s
    }
    
    func redirect(url u: String) {
        
        self.statusCode = 302
        self.headers["Location"] = u
        self.send()
    }
    
    
    func sendFile(data: NSData, fileType: NSString) {
        
        self.body = data
        self.headers["Content-Type"] = fileType
        
        self.send()
    }
    
    func sendError(errorCode: Int){
        
        self.statusCode = errorCode
        
        if let a = self.codes[self.statusCode]{
            
            self.stringBody = a
        }
        
        self.send()
        
    }
    public func send() {
        
        assert(!self.sent)
        self.sent = true
        
        if socket {
            
            socket!.writeData(self.generateResponse(), withTimeout: 10, tag: 1)
        }
        
    }
    
    internal func generateResponse() -> NSData {
        
        if let a = self.codes[self.statusCode]{
            
            self.statusLine = a
        }
        
        var bodyData: NSData = NSData()
        
        if body {
            bodyData = body!
        } else if stringBody {
            bodyData = NSData(data: stringBody!.dataUsingEncoding(NSUTF8StringEncoding))
        }
        
        if !headers["Content-Length"] {
            headers["Content-Length"] = String(bodyData.length)
        }
        
        var startLine = "\(self.http_protocol) \(String(self.statusCode)) \(self.statusLine)\r\n"
        
        var headersStr = ""
        for (k, v) in self.headers {
            
            headersStr += "\(k): \(v)\r\n"
        }
        
        headersStr += "\r\n"
        var finalStr = String(startLine+headersStr)
        
        var data: NSMutableData = NSMutableData(data: finalStr.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false))
        data.appendData(bodyData)
        
        return data as NSData
    }
}