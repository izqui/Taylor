//
//  request.swift
//  TaylorTest
//
//  Created by Jorge Izquierdo on 19/06/14.
//  Copyright (c) 2014 Jorge Izquierdo. All rights reserved.
//

import Foundation

class Request {
    
    enum HTTPMethod: String {
        
        case GET = "GET"
        case POST = "POST"
        case UNDEFINED = "UNDEFINED" // it will never match
    }
    
    var path: String = String()
    var pathComponents: String[] = String[]()
    
    var arguments: Dictionary<String, String> = Dictionary<String, String>() // ?hello=world -> arguments["hello"]
    var parameters: Dictionary<String, String> = Dictionary<String, String>() // /:something -> parameters["something"]
    
    var method: HTTPMethod = .UNDEFINED
    var headers: Dictionary<String, String> = Dictionary<String, String>()
    
    //var bodyData: NSData?
    var bodyString: NSString?
    var body: Dictionary<String, String> = Dictionary<String, String>()
    
    var _protocol: String?
    
    init(data d: NSData){
        
        //Parsing data from socket to build a HTTP request
        self.parseRequest(d)
    }
    
    func parseRequest(d: NSData){
        
        //TODO: Parse data line by line, so if body content is not UTF8 encoded, this doesn't crash
        var string = NSString(data: d, encoding: NSUTF8StringEncoding)
        
        var http: String[] = string.componentsSeparatedByString("\r\n") as String[]
        
        //Parse method
        if http.count > 0 {
            
            var startLineArr: String[] = http[0].componentsSeparatedByString(" ") //One space
            
            if startLineArr.count > 0 {
                
                if let m = HTTPMethod.fromRaw(startLineArr[0]) {
                    
                    self.method = m
                }
            }
            
            //Parse URL
            if startLineArr.count > 1 {
                
                var url = startLineArr[1]
                var urlElements: String[] = url.componentsSeparatedByString("?") as String[]
                
                self.path = urlElements[0]
                var comps = self.path.componentsSeparatedByString("/")
                
                //We don't care about the first element, which will always be nil since paths are like this: "/something"
                for i in 1..comps.count {
                    
                    self.pathComponents += comps[i]
                }
            
                if urlElements.count == 2 {
                    
                    var args = urlElements[1].componentsSeparatedByString("&") as String[]
                    
                    for a in args {
                        
                        var arg = a.componentsSeparatedByString("=") as String[]
                        
                        //Would be nicer changing it to something that checks if element in array exists
                        var value = ""
                        if arg.count > 1 {
                            value = arg[1]
                        }
                        
                        // Adding the values removing the %20 bullshit and stuff
                        self.arguments.updateValue(value.stringByReplacingPercentEscapesUsingEncoding(NSASCIIStringEncoding), forKey: arg[0].stringByReplacingPercentEscapesUsingEncoding(NSASCIIStringEncoding))
                    }
                }
            }
            
            //TODO: Parse HTTP version
            if startLineArr.count > 2{
                
                _protocol = startLineArr[2]
            }
        }
        
        //Parse Headers
        var i = 1
        
        while ++i < http.count {
            
            var content = http[i]
            
            if content == "" {
                // This newline means headers have ended and body started (New line already got parsed ("\r\n"))
                break
            }
            var header = content.componentsSeparatedByString(": ") as String[]
            if header.count == 2 {
                
                self.headers.updateValue(header[1], forKey: header[0])
            }
        }
        
        if i < http.count && (self.method == .POST || false) { // Add other methods that support body data
            
            println("We have body data")
            var str = NSMutableString()
            while ++i < http.count {
                
                str.appendString("\(str)\n")
    
            }
            
            self.bodyString = str
        }
    }
}
