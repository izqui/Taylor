//
//  middleware.swift
//  Taylor
//
//  Created by Jorge Izquierdo on 23/06/14.
//  Copyright (c) 2014 Jorge Izquierdo. All rights reserved.
//

import Foundation

class Middleware {
    
    class func bodyParser() -> TaylorHandler {
        
        return {
            
            request, response in
            
            if request.bodyString {
                
                if request.headers["Content-Type"] == "multipart/form-data" || request.headers["Content-Type"] == "application/x-www-form-urlencoded" {
                    
                    var args = request.bodyString!.componentsSeparatedByString("&") as String[]
                    
                    for a in args {
                        
                        var arg = a.componentsSeparatedByString("=") as String[]
                        
                        //Would be nicer changing it to something that checks if element in array exists
                        var value = ""
                        if arg.count > 1 {
                            value = arg[1]
                        }
                        
                        request.body.updateValue(value.stringByReplacingPercentEscapesUsingEncoding(NSASCIIStringEncoding), forKey: arg[0].stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding))
                    }
                }
            }
            
            return (request: request, response: response)
        }
    }
    
    class func staticDirectory(path: String, directory: String) -> TaylorHandler {
        
        return {
            
            request, response in
            
            return (request: request, response: response)
        }
    }
    
    class func requestLogger() -> TaylorHandler {
        
        return {
            
            request, response in
            
            println("[Taylor] \(request.method.toRaw()) \(request.path)")
            
            return (request: request, response: response)
        }
    }
}