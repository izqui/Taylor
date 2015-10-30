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

public typealias Handler = (Request, Response, (Callback) -> ()) -> ()
internal typealias PathComponent = (value: String, isParameter: Bool)

public enum HTTPMethod: String {
        
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case HEAD = "HEAD"
    case UNDEFINED = "UNDEFINED" // it will never match
}


public class Server {
    
    private var socket: SocketServer = CurrentSocket()
    
    private var handlers: [Handler]
    private var postRequestHandlers: [Handler]
    
    public var notFoundHandler: Handler = {
        req, res, cb in
        res.setError(404)
        cb(.Send(req, res))
    }
    var router: Router
    
    public init(){
        
        router = Router()
        self.handlers = []
        self.postRequestHandlers = []
    }
    
    public func serveHTTP(port p: Int, forever: Bool) throws {
        
        socket.receivedRequestCallback = {
            request, socket in
            self.handleRequest(socket, request: request, response: Response())
            return true
        }
        try socket.startOnPort(p)
            
            //Should find a better location for this
        self.addHandler(self.router.handler())
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
    
    public func addHandler(handler: Handler){
        
        //Should check if middleare has already been added, but it's difficult since it is a clousure and not an object
        self.handlers.append(handler)
    }
    
    public func addPostRequestHandler(handler: Handler){
        self.postRequestHandlers.append(handler)
    }
    
    internal func handleRequest(socket: Socket, request: Request, response: Response) {
        
        var j = -1
        var postRequest: ((Callback)->())!
        postRequest = {
            a in
            switch a {
            case .Continue(let req, let res):
                j = j+1
                if j < self.postRequestHandlers.count {
                    self.postRequestHandlers[j](req, res, postRequest)
                }
            case .Send(_, _):
                print("Attempting to send a response twice")
            }
        }
        
        var cb: ((Callback)->())!
        var i = -1
        cb = {
            a in
            switch a {
            case .Continue(let req, let res):
                i = i+1
                if i < self.handlers.count {
                    self.handlers[i](req, res, cb)
                } else {
                    self.notFoundHandler(req, res, cb)
                }
            case .Send(let req, let res):
                let data = res.generateResponse(req.method)
                
                socket.sendData(data)
                postRequest(.Continue(req, res))
            }
        }
        
        cb(.Continue(request, response))
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
    
}