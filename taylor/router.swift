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
    var _middleware: TaylorHandler[] = TaylorHandler[]()
    
    func addRoute(route: Route) -> Bool {
        
        // Check for conflicts before adding it
        for r in _routes {
            
            if r.path == route.path && r.method == route.method {
                return false
            }
        }
        
        self._routes += route
        return true
    }
    
    func addMiddleware(middleware: TaylorHandler) {
        
        self._middleware += middleware
    }
    
    func handleRequest(request: Request, response: Response) -> Bool {
        
        //TODO: Make this shit asyncronous
        for route in _routes {
            
            switch (route.path, route.method) {
            case (request.path, request.method):
                
                var t: TaylorTuple = (request: request, response: response)
                
                for mid in self._middleware {
                    
                    if let tuple = mid(request: t.request, response: t.response) {
                        // Continue
                        t = tuple
                    }
                    else {
                        
                        return true
                    }
                }
                //Execute all handlers
                for handler in route.handlers {
                    
                    if let tuple = handler(request: t.request, response: t.response) {
                        // Continue
                        t = tuple
                    }
                    else {
                        
                        return true
                    }
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

