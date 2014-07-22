//
//  router.swift
//  TaylorTest
//
//  Created by Jorge Izquierdo on 19/06/14.
//  Copyright (c) 2014 Jorge Izquierdo. All rights reserved.
//

import Foundation

public class Router {
    
    var _routes: [Route] = [Route]()
    
    func addRoute(route: Route) -> Bool {
        
        self._routes += route
        return true
    }
    
    public func handler() -> Taylor.TaylorHandler {
        
        return {
            
            request, response in
            
            if let route = self.detectRouteForRequest(request){
                
                //Execute all handlers
                for handler in route.handlers {
                    
                    handler(request: request, response: response)
                    if response.sent { break }
                }
            }
        }
    }
    
    private func detectRouteForRequest(request: Request) -> Route? {
        
        for route in self._routes {
            
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
    
    func 😕(request: Request, response: Response) -> Bool {
        
        response.sendError(404)
        return true
    }
}

