//
//  router.swift
//  TaylorTest
//
//  Created by Jorge Izquierdo on 19/06/14.
//  Copyright (c) 2014 Jorge Izquierdo. All rights reserved.
//

import Foundation

public class Router {
    
    private var routes: [Route] = [Route]()
    
    public func addRoute(route: Route) -> Bool {
        
        routes.append(route)
        return true
    }
    
    public func handler() -> Handler {
        
        return {
            
            request, response, callback in
            
            if let route = self.detectRouteForRequest(request as Request){
                
                //Execute all handlers
                var cb: ((Callback)->())!
                var i = -1
                cb = {
                    a in
                    switch a {
                    case .Continue(let req, let res):
                        i = i+1
                        if i < route.handlers.count {
                            route.handlers[i](req, res, cb)
                        } else {
                            callback(.Continue(req, res))
                        }
                    case .Send(let req, let res):
                        
                        callback(.Send(req, res))
                    }
                }
                
                cb(.Continue(request, response))
            } else {
                callback(.Continue(request, response))
            }
        }
    }
    
    private func detectRouteForRequest(request: Request) -> Route? {
        
        for route in routes {
            
            request.parameters = Dictionary<String, String>()
            let compCount = route.pathComponents.count
            if route.method == request.method && compCount == request.pathComponents.count {
                
                for i in 0..<compCount {
                    
                    var isParameter = route.pathComponents[i].isParameter
                    if !(isParameter || route.pathComponents[i].value == request.pathComponents[i]) {
                        
                        request.parameters = [:]
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
    
}

