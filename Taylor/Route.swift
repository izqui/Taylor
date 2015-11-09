//
//  route.swift
//  TaylorTest
//
//  Created by Jorge Izquierdo on 19/06/14.
//  Copyright (c) 2014 Jorge Izquierdo. All rights reserved.
//

public class Route: Routable, RoutableEndPoint {
    
    public let method: HTTPMethod
    public let path: Path
    public let handlers: [Routable] = []
    
    // Required by RoutableEndPoint, called from handleRequest()
    public let handlerClosures: [Handler]
    
    public required init(m: HTTPMethod, path p: String, handlers s: [Handler]){
        self.method = m
        self.handlerClosures = s
        self.path = Path(path: p)
    }
    
    public func matchesRequest(request: Request) -> Bool {
        if self.method == request.method && path.matchesRequest(request) {
            return true
        }
        
        return false
    }
    
    public func handleRequest(request: Request, response: Response) -> Callback {
        return executeHandlerClosures(forRequest: request, response: response)
    }
}
