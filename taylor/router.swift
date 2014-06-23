//
//  router.swift
//  TaylorTest
//
//  Created by Jorge Izquierdo on 19/06/14.
//  Copyright (c) 2014 Jorge Izquierdo. All rights reserved.
//

import Foundation

class Router {
    
    var _routes: Route[] = Route[]()
    
    func addRoute(route: Route) -> Bool {
        
        //TODO: Should check for conflicts before adding it
        _routes += route
        
        return true
    }
    
    func handleRequest(request: Request, response: Response) -> Bool {
        
        //TODO: Make this shit asyncronous
        for route in _routes {
            
            switch (route.path, route.method) {
            case (request.path, request.method):
                
                println("\(request.method.toRaw()) -> \(request.path)")
                
                if let t = route.callback(request: request, response: response) {
                    // Continue
                }
                else {
                    
                    return true
                }
                
            default:
                continue
            }
        }
        
        println("\(request.method.toRaw()) \(request.path) not implemented")
        return self.😕(request, response: response)
    }
    
    func 😕(request: Request, response: Response) -> Bool {
        
        let resp = Response(socket: response._socket)
        resp.statusCode = 404
        resp.send()
        
        return true
    }
}

