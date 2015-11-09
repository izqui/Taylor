//
//  taylor.swift
//  TaylorTest
//
//  Created by Jorge Izquierdo on 18/06/14.
//  Copyright (c) 2014 Jorge Izquierdo. All rights reserved.
//

import Foundation

let CurrentSocket: Void -> SocketServer = {
    return SwiftSocketServer()
}

public enum Callback {
    case Continue(Request, Response)
    case Send(Request, Response)
}

public typealias Handler = (Request, Response) -> Callback

public enum HTTPMethod: String {
    
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case HEAD = "HEAD"
    case UNDEFINED = "UNDEFINED" // it will never match
}

public class Server {
    
    private var socket: SocketServer = CurrentSocket()
    var router: Router = Router()
    
    public init(){
        
    }
    
    public func serveHTTP(port p: Int, forever: Bool) throws {
        
        socket.receivedRequestCallback = {
            request, socket in
            self.handleRequest(socket, request: request, response: Response())
            return true
        }
        try socket.startOnPort(p)
        
        if forever {
            
            // So the program doesn't end
            while true {
                // need to get rid of this somehow...
                NSRunLoop.mainRunLoop().run()
            }
        }
    }
    public func stopListening() {
        
        socket.disconnect()
    }
    
    internal func handleRequest(socket: Socket, request: Request, response: Response) {
        
        let result = self.router.handleRequest(request, response: response)
        switch result {
        case .Continue(_, _):
            // Nothing left to call, send 404
            self.router.notFoundHandler(request, response)
            print("")
        case .Send(_, _):
            print("")
        }
        
        let data = response.generateResponse(request.method)
        socket.sendData(data)
        
        self.router.callAfterHooks(request, response: response)
    }
    
    //Convenience methods
    public func get(p: String, _ c: Handler...) {
        
        self.router.addRoute(Route(m: .GET, path: p, handlers: c))
    }
    
    public func post(p: String, _ c: Handler...) {
        
        self.router.addRoute(Route(m: .POST, path: p, handlers: c))
    }
    
    public func put(p: String, _ c: Handler...) {
        
        self.router.addRoute(Route(m: .PUT, path: p, handlers: c))
    }
    
    public func use(p: String, _ c: Handler...) {
        self.router.addBeforeHook(Middleware(path: p, handlers: c))
    }
    
}
