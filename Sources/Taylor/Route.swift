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
    public var handlers: [Routable] = []
    
    public required init(m: HTTPMethod, path p: String, handlers s: [Handler]){
        
        self.method = m
        self.path = Path(path: p)
        
        for handler in s {
            self.handlers.append(RouteHandler(handler: handler))
        }
    }
    
    public func matchesRequest(request: Request) -> Bool {
        
        if self.method == request.method && path.matchesRequest(request) {
            return true
        }
        
        return false
    }
}
