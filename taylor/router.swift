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
        
        for r in _routes {
            
            if r.path == request.path && r.method == request.method {
                
                return r.callback(request: request, response: response)
            }
        }
        
        return self.😕(request, response: response)
        
    }
    
    func 😕(request: Request, response: Response) -> Bool {
        
        println("404 bro")
        return true
    }
}

