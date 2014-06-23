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
        case UNDEFINED = ""
    }
    
    var path: String = String()
    var arguments: Dictionary<String, String> = Dictionary<String, String>()
    
    var method: HTTPMethod = .UNDEFINED
    var headers: Dictionary<String, String> = Dictionary<String, String>()
    
    var _protocol: String?
    
    init(data d: NSData){
        
        //Parsing data from socket to build a HTTP request
        self.parseRequest(d)
    }
    
    func parseRequest(d: NSData){
        
        var string = NSString(data: d, encoding: NSUTF8StringEncoding)
        
        var http: String[] = string.componentsSeparatedByString("\n") as String[]
        
        //Parse method
        if http.count > 0 {
            
            var startLineArr: String[] = http[0].componentsSeparatedByString(" ") //One space
            
            if startLineArr.count > 0 {
                
                if let m = HTTPMethod.fromRaw(startLineArr[0]) {
                    
                    self.method = m
                }
                else {
        
                    self.method = .UNDEFINED
                }
                
            }
            
            //Parse URL
            if startLineArr.count > 1 {
                
                var url = startLineArr[1]
                var urlElements: String[] = url.componentsSeparatedByString("?") as String[]
                
                self.path = urlElements[0]
                if urlElements.count == 2 {
                    
                    var args = urlElements[1].componentsSeparatedByString("&") as String[]
                    
                    for a in args {
                        
                        var arg = a.componentsSeparatedByString("=") as String[]
                        
                        //Would be nicer changing it to something that checks if element in array exists
                        var value = ""
                        if arg.count > 1 {
                            value = arg[1]
                        }
                        
                        self.arguments.updateValue(value, forKey: arg[0])
                    }
                }
            }
            
            //TODO: Parse HTTP version
            if startLineArr.count > 2{
                
                _protocol = startLineArr[2]
            }
        }
        
        //Parse Headers
        for i in 1..http.count {
            
            var header = http[i].componentsSeparatedByString(": ") as String[]
            if header.count == 2 {
                
                self.headers.updateValue(header[1], forKey: header[0])
            }
        }
        //println("REQUEST: method \(self.method) path \(self.path) header \(self.headers) arguments \(self.arguments)")
    }
}
