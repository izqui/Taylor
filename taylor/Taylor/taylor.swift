//
//  taylor.swift
//  TaylorTest
//
//  Created by Jorge Izquierdo on 18/06/14.
//  Copyright (c) 2014 Jorge Izquierdo. All rights reserved.
//

import Foundation

public enum Callback {
    case Continue(Request, Response)
    case Send(Request, Response)
}

public typealias Handler = (Request, Response, (Callback) -> ()) -> ()
internal typealias PathComponent = (value: String, isParameter: Bool)

public enum Result {
    case Success
    case Error(NSError)
}

public enum HTTPMethod: String {
        
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case UNDEFINED = "UNDEFINED" // it will never match
}

public class Server: NSObject, GCDAsyncSocketDelegate {
    
    private var socket: GCDAsyncSocket
    
    private var sockets: [GCDAsyncSocket] = [GCDAsyncSocket]()
    private var handlers: [Handler]
    private var postRequestHandlers: [Handler]
    
    public var notFoundHandler: Handler = {
        req, res, cb in
        res.setError(404)
        cb(.Send(req, res))
    }
    var router: Router
    
    public override init(){
        
        router = Router()
        self.handlers = []
        self.postRequestHandlers = []
        
        socket = GCDAsyncSocket()
    }
    
    public func startListening(port p: Int, forever awake: Bool, callback:((Result)->())?){
        
        socket.setDelegate(self, delegateQueue: dispatch_get_main_queue())
        
        var err: NSError?
        
        if socket.acceptOnInterface(nil, port: UInt16(p), error: &err) {
            
            callback?(.Success)
            
            //Should find a better location for this
            self.addHandler(self.router.handler())
        }
        else if err != nil {
            
            callback?(.Error(err!))
        }
        
        if awake {
            
            // So the program doesn't end
            while true {
                
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
    
    internal func handleRequest(socket: GCDAsyncSocket, request: Request, response: Response) {
        
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
            case .Send(let req, let res):
                println("Attempting to send a response twice")
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
                socket.writeData(res.generateResponse(), withTimeout: 10, tag: 1)
                socket.disconnectAfterWriting()
                postRequest(.Continue(req, res))
            }
        }
        
        cb(.Continue(request, response))
    }
    
    // GCDAsyncSocketDelegate methods
    public func socket(socket: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket){
        
        newSocket.readDataWithTimeout(10, tag: 1)
    }
    
    public func socket(sock: GCDAsyncSocket!, didReadData data: NSData!, withTag tag: Int) {
        
        var request = Request(data: data)
        var response = Response(socket: sock)
        
        self.handleRequest(sock, request: request, response: response)
    }
    
    public func socketDidDisconnect(sock: GCDAsyncSocket, withError err: NSError){
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