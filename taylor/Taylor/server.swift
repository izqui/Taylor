//
//  server.swift
//  Taylor
//
//  Created by Jorge Izquierdo on 22/07/14.
//  Copyright (c) 2014 Jorge Izquierdo. All rights reserved.
//

import Foundation

public class TServer: NSObject, TServerProtocol, GCDAsyncSocketDelegate {
    
    private var socket: GCDAsyncSocket
    
    private var sockets: [GCDAsyncSocket] = [GCDAsyncSocket]()
    private var handlers: [Taylor.Handler]
    
    var router: TRouter
    
    public override init(){

        router = TRouter()
        handlers = []
        
        socket = GCDAsyncSocket()
    }
    
    public func startListening(port p: Int, forever awake: Bool){
        
        socket.setDelegate(self, delegateQueue: dispatch_get_main_queue())
        
        var err: NSError?
        
        if socket.acceptOnInterface(nil, port: UInt16(p), error: &err) {
            
            println("Server running on port \(socket.localPort())")
            
            //Should find a better location for this
            self.addHandler(self.router.handler())
        }
        else if err != nil {
            
            println("Error \(err!)")
        }
        else {
            
            println("wtf")
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
    
    public func addHandler(handler: Taylor.Handler){
        
        //Should check if middleare has already been added, but it's difficult since it is a clousure and not an object
        self.handlers.append(handler)
    }
    
    internal func handleRequest(request: TRequest, response: TResponse, cb:() -> ()) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            
            for han in self.handlers {
                
                han(request: request, response: response)
                if response.sent { break }
            }
            
            //TODO: 404 as the default last handler
            if !response.sent {
                println("wat")
                response.sendError(404)
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                
                cb()
            }
        }
    }
    
    // GCDAsyncSocketDelegate methods
    public func socket(socket: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket){
        
        newSocket.readDataWithTimeout(10, tag: 1)
    }
    
    public func socket(sock: GCDAsyncSocket!, didReadData data: NSData!, withTag tag: Int) {
        
        var request = TRequest(data: data)
        var response = TResponse(socket: sock)
        
        self.handleRequest(request, response: response) {
            
            sock.disconnectAfterWriting()
            
        }
    }
    
    public func socketDidDisconnect(sock: GCDAsyncSocket, withError err: NSError){
    }
    
    //Convenience methods
    public func get(p: String, callback c: Taylor.Handler...) {
        
        self.router.addRoute(TRoute(m: .GET, path: p, handlers: c))
    }
    
    public func post(p: String, callback c: Taylor.Handler...) {
        
        self.router.addRoute(TRoute(m: .POST, path: p, handlers: c))
    }
}