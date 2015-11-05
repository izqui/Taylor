//
//  response.swift
//  TaylorTest
//
//  Created by Jorge Izquierdo on 19/06/14.
//  Copyright (c) 2014 Jorge Izquierdo. All rights reserved.
//

import Foundation

public class Response {
    
    private var statusLine: String = ""
    
    public var statusCode: Int = 200
    public var headers = [String:String]()
    
    public var body: NSData?
    public var bodyString: String? {
        didSet {
            if headers["Content-Type"] == nil {
                headers["Content-Type"] = FileTypes.get("txt")
            }
        }
    }
    
    var bodyData: NSData {
        if let b = body {
            return b
        } else if bodyString != nil {
            return NSData(data: bodyString!.dataUsingEncoding(NSUTF8StringEncoding)!)
        }
        
        return NSData()
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
        
        400: "Bad TRequest",
        401: "Unauthorized",
        403: "Forbidden",
        404: "Not Found",
        
        500: "Internal Server Error",
        502: "Bad Gateway",
        503: "Service Unavailable"
    ]
    
    public func redirect(url u: String) {
        
        self.statusCode = 302
        self.headers["Location"] = u
    }
    
    
    public func setFile(url: NSURL?) {
        
        if let u = url, let data = NSData(contentsOfURL: u) {
            self.body = data
            self.headers["Content-Type"] = FileTypes.get(u.pathExtension ?? "")
        } else {
            self.setError(404)
        }
    }
    
    public func setError(errorCode: Int){
        
        self.statusCode = errorCode
        
        if let a = self.codes[self.statusCode]{
            
            self.bodyString = a
        }
    }
    
    func headerData() -> NSData {
        
        if let a = self.codes[self.statusCode]{
            
            self.statusLine = a
        }
        
        if headers["Content-Length"] == nil{
            headers["Content-Length"] = String(bodyData.length)
        }
        
        let startLine = "\(self.http_protocol) \(String(self.statusCode)) \(self.statusLine)\r\n"
        
        var headersStr = ""
        for (k, v) in self.headers {
            
            headersStr += "\(k): \(v)\r\n"
        }
        
        headersStr += "\r\n"
        let finalStr = String(format: startLine+headersStr)
        
        return NSMutableData(data: finalStr.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!)
    }
    
    internal func generateResponse(method: HTTPMethod) -> NSData {
        
        let headerData = self.headerData()
        
        guard method != .HEAD else { return headerData }
        return headerData + self.bodyData
        
    }
}