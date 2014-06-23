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
                
                println("parsing body \(request.bodyString!)")
            }
            
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