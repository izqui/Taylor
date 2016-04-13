//
//  RouteHandler.swift
//  Taylor
//
//  Created by Kevin Sullivan on 11/9/15.
//  Copyright © 2015 Jorge Izquierdo. All rights reserved.
//

import Foundation

public class RouteHandler: Routable {
    
    public let path: Path = Path(path: "")
    public let handlers: [Routable] = []
    
    var handler: Handler
    
    public init(handler: Handler) {
        
        self.handler = handler
    }
    
    public func matchesRequest(request: Request) -> Bool {
        
        return true
    }
    
    public func handleRequest(request: Request, response: Response) -> Callback {
        
        return handler(request, response)
    }
}
