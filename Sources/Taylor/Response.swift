//
//  response.swift
//  TaylorTest
//
//  Created by Jorge Izquierdo on 19/06/14.
//  Copyright (c) 2014 Jorge Izquierdo. All rights reserved.
//

import Foundation

public class Response {
    
    public var statusLine: String {
        return status.statusLine()
    }
    public var statusCode: Int {
        return status.rawValue
    }
    
    public var status: HTTPStatus = .OK
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
    public func redirect(url u: String) {
        
        self.status = .Found
        self.headers["Location"] = u
    }
    
    
    public func setFile(url: NSURL?) {
        
        if let u = url, let data = NSData(contentsOfURL: u) {
            self.body = data
            self.headers["Content-Type"] = FileTypes.get(u.pathExtension ?? "")
        } else {
            self.setError(.NotFound)
        }
    }
    
    public func setError(errorStatus: HTTPStatus){
        self.status = errorStatus
    }
    
    func headerData() -> NSData {
        
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

public enum HTTPStatus: Int {
    
    case OK = 200
    case Created = 201
    case Accepted = 202
    
    case MultipleChoices = 300
    case MovedPermanently = 301
    case Found = 302
    case SeeOther = 303
    
    case BadRequest = 400
    case Unauthorized = 401
    case Forbidden = 403
    case NotFound = 404
    
    case InternalServerError = 500
    case BadGateway = 502
    case ServiceUnavailable = 503
    
    func statusLine() -> String {
        switch self {
        case .OK: return "OK"
        case .Created: return "Created"
        case .Accepted: return "Accepted"
        
        case .MultipleChoices: return "Multiple Choices"
        case .MovedPermanently: return "Moved Permentantly"
        case .Found: return "Found"
        case .SeeOther: return "See Other"
        
        case .BadRequest: return "Bad Request"
        case .Unauthorized: return "Unauthorized"
        case .Forbidden: return "Forbidden"
        case .NotFound: return "Not Found"
        
        case .InternalServerError: return "Internal Server Error"
        case .BadGateway: return "Bad Gateway"
        case .ServiceUnavailable: return "Service Unavailable"
        }
    }
}
