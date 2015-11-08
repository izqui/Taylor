//
//  router.swift
//  TaylorTest
//
//  Created by Jorge Izquierdo on 19/06/14.
//  Copyright (c) 2014 Jorge Izquierdo. All rights reserved.
//

public class Router {
    
    private var routes: [Route] = [Route]()
    
    public func addRoute(route: Route) -> Bool {
        
        routes.append(route)
        return true
    }
    
    public func handler() -> Handler {
        
        return {
            
            request, response, callback in
            
            if let route = self.detectRouteForRequest(request){
                
                let callbackHandler = CallbackHandler(handlers: route.handlers)
                
                callbackHandler.onContinueWithNoHandlersLeft = { req, res, _ in
                    // outer callback (kind of confusing)
                    callback(.Continue(req, res))
                }
                callbackHandler.onSend = { req, res, _ in
                    // outer callback (kind of confusing)
                    callback(.Send(req, res))
                }
                
                callbackHandler.start(request, response)
            } else {
                callback(.Continue(request, response))
            }
        }
    }
    
    private func detectRouteForRequest(request: Request) -> Route? {
        
        for route in routes {
            
            request.parameters = Dictionary<String, String>()

            let compatibleMethods = (route.method == request.method) || (route.method == .GET && request.method == .HEAD)

            let componentCount = route.pathComponents.count

            if compatibleMethods && (componentCount == request.pathComponents.count) {
                
                for i in 0..<componentCount {
                    
                    let isParameter = route.pathComponents[i].isParameter
                    if !(isParameter || route.pathComponents[i].value == request.pathComponents[i]) {
                        
                        request.parameters = [:]
                        break
                    }
                    
                    if isParameter {
                        
                        request.parameters[route.pathComponents[i].value] = request.pathComponents[i]
                    }

                    if i == componentCount - 1 {
                        return route
                    }
                }
            }
        }
        
        return nil
    }
    
}
