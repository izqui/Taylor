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
        
        self._routes += route
        return true
    }
    
    func addMiddleware(middleware: TaylorHandler) {
        
        self._middleware += middleware
    }
    
    func handleRequest(request: Request, response: Response) -> Bool {
        
        //TODO: Make this shit asyncronous
        var t: TaylorHandlerTuple = (request: request, response: response)
        
        for mid in self._middleware {
            
            if let tuple = mid(request: t.request, response: t.response) {
                // Continue
                t = tuple
            }
            else {
                
                return true
            }
        }
        
        if let route = self.detectRouteForRequest(request){
            
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
            
        }
        
        return self.😕(request, response: response)
        
    }
    
    func detectRouteForRequest(request: Request) -> Route? {
        
        for route in self._routes {
            
            request.parameters = Dictionary<String, String>()
            let compCount = route.pathComponents.count
            if route.method == request.method && compCount == request.pathComponents.count {
                
                for i in 0..compCount {
                    
                    var isParameter = route.pathComponents[i].isParameter
                    if !(isParameter || route.pathComponents[i].value == request.pathComponents[i]) {
                        
                        break
                    }
                    
                    if isParameter {
                        
                        request.parameters[route.pathComponents[i].value] = request.pathComponents[i]
                    }

                    if i == compCount - 1 {
                        return route
                    }
                }
            }
        }
        
        return nil
    }
    
    func 😕(request: Request, response: Response) -> Bool {
        
        let resp = Response(socket: response._socket)
        resp.statusCode = 404
        resp.send()
        
        return true
    }
}

