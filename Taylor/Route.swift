//
//  route.swift
//  TaylorTest
//
//  Created by Jorge Izquierdo on 19/06/14.
//  Copyright (c) 2014 Jorge Izquierdo. All rights reserved.
//

public class Route: Routable {
    
    public let method: HTTPMethod
    public let path: Path
    
    // The handlers passed in are guaranteed to always be called, so handlers is ignored
    public let handlers: [Routable] = []
    
    // Instead, we store just the closures and iterate through them in handleRequest()
    public let handlerClosures: [Handler]
    
    public required init(m: HTTPMethod, path p: String, handlers s: [Handler]){
        self.method = m
        self.handlerClosures = s
        self.path = Path(path: p)
    }
    
    public func matchesRequest(request: Request) -> Bool {
        var parameters: [String : String] = [:]
        let componentCount = self.path.components.count
        
        if componentCount == request.pathComponents.count && self.method == request.method {
            
            for i in 0..<componentCount {
                let pathComponent = self.path.components[i]
                
                switch pathComponent {
                case .Static(let componentString):
                    if componentString != request.pathComponents[i] {
                        return false
                    }
                case .Parameter(let parameterString):
                    parameters[parameterString] = request.pathComponents[i]
                }
            }
            
            request.parameters = parameters
            return true
        }
        
        return false
    }
    
    public func handleRequest(request: Request, response: Response) -> Callback {
        for handler in handlerClosures {
            // Always check result to see if we shoud return early
            let result = handler(request, response)
            if case .Send(_, _) = result {
                return result
            }
        }
        
        // If we didn't already return, we know to return .Continue
        return .Continue(request, response)
    }
}
