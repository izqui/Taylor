//
//  server.swift
//  Taylor
//
//  Created by Jorge Izquierdo on 22/07/14.
//  Copyright (c) 2014 Jorge Izquierdo. All rights reserved.
//

import Foundation

public class Server: ServerProtocol {
    
    private let port: Int = 8080
    private var socket: GCDAsyncSocket?
    
    private var sockets: [GCDAsyncSocket] = [GCDAsyncSocket]()
    private var handlers: [Taylor.TaylorHandler]
    
    var router: Router
    
    public init(){

        router = Router()
        handlers = []
        
        self.setup()
    }
    
    private func setup(){
        
        socket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
    }
    
    public func startListening(port p: Int, forever awake: Bool){
        
        var err: NSError?
        
        if socket?.acceptOnInterface(nil, port: UInt16(port), error: &err) {
            
            println("Server running on port \(socket!.localPort())")
            
            //Should find a better location for this
            self.addHandler(self.router.handler())
        }
        else if err {
            
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
        
        socket?.disconnect()
    }
    
    public func addHandler(handler: Taylor.TaylorHandler){
        
        //Should check if middleare has already been added, but it's difficult since it is a clousure and not an object
        self.handlers += handler
    }
    
    internal func handleRequest(request: Request, response: Response, cb:() -> ()) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            
            for han in self.handlers {
                
                han(request: request, response: response)
                if response.sent { break }
            }
            
            //TODO: 404 as the default last handler
            if !response.sent {
                
                response.sendError(404)
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                
                cb()
            }
        }
    }
    // GCDAsyncSocket delegate methods
    
    public func socket(socket: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket){
        
        newSocket.readDataWithTimeout(10, tag: 1)
    }
    
    public func socket(sock: GCDAsyncSocket, didReadData data: NSData, withTag tag: Double){
        
        var request = Request(data: data)
        var response = Response(socket: sock)
        
        self.handleRequest(request, response: response) {
            
            sock.disconnectAfterWriting()
            
        }
    }
    
    /*
    //- (void)socket:(GCDAsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag;
    func socket(sock: GCDAsyncSocket, didReadPartialDataOfLength length: Int, tag t: Double){
    
    }*/
    
    //- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err;
    public func socketDidDisconnect(sock: GCDAsyncSocket, withError err: NSError){
    }
    
    //Convenience methods
    public func get(p: String, callback c: Taylor.TaylorHandler...) {
        
        self.router.addRoute(Route(m: .GET, path: p, handlers: c))
    }
    
    public func post(p: String, callback c: Taylor.TaylorHandler...) {
        
        self.router.addRoute(Route(m: .POST, path: p, handlers: c))
    }
}