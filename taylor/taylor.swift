//
//  taylor.swift
//  TaylorTest
//
//  Created by Jorge Izquierdo on 18/06/14.
//  Copyright (c) 2014 Jorge Izquierdo. All rights reserved.
//

import Foundation

//Makes the compiler crash
//typealias TaylorHandler = (inout request: Request, inout response: Response) -> (ok: Bool)
typealias TaylorHandlerTuple = (request: Request, response: Response)
typealias TaylorPathComponent = (value: String, isParameter: Bool)
typealias TaylorHandler = TaylorHandlerTuple -> TaylorHandlerTuple?

class Taylor: NSObject, GCDAsyncSocketDelegate {
    
    let _port: Int
    var _socket: GCDAsyncSocket?
    
    var _sockets: GCDAsyncSocket[] = GCDAsyncSocket[]()
    var _handlers: TaylorHandler[] = TaylorHandler[]()
    
    var router: Router {
    
   
    willSet (newOne){
        
        // When setting a new router, set the routes of the old one
        for r in router._routes {
            newOne.addRoute(r)
    }
    }
    }
    
    init(port p: Int){
        
        _port = p
        router = Router()
        
        super.init()
        self.setup()
    }
    
    func setup(){
        
        _socket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
    }
    
    func startListening(forever awake: Bool){
        
        var err: NSError?
        
        if _socket!.acceptOnInterface(nil, port: UInt16(_port), error: &err) {
            
            println("Server running on port \(_socket!.localPort())")
            
            //Should find a better location for this
            self.use(self.router.handler())
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
    
    func use(middleware: TaylorHandler){
        
        //Should check if middleare has already been added, but it's difficult since it is a clousure and not an object
        self._handlers += middleware
    }
    
    func handleRequest(request: Request, response: Response, cb:() -> ()) {
        
        var t: TaylorHandlerTuple = (request: request, response: response)
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            
            for han in self._handlers {
                
                if let tuple = han(request: t.request, response: t.response) {
                    // Continue
                    t = tuple
                }
            }
            
            if t.response.sent == false {
                
                println("Response not sent, 404")
                t.response.sendError(404)
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                
                cb()
            }
        }
    }
    // GCDAsyncSocket delegate methods
    
    func socket(socket: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket){
        
        newSocket.readDataWithTimeout(10, tag: 1)
    }
    
    func socket(sock: GCDAsyncSocket, didReadData data: NSData, withTag tag: Double){
        
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
    func socketDidDisconnect(sock: GCDAsyncSocket, withError err: NSError){
    }

    //Convenience methods
    func get(p: String, callback c: TaylorHandler...) {
        
        self.router.addRoute(Route(m: .GET, path: p, handlers: c))
    }
    
    func post(p: String, callback c: TaylorHandler...) {
        
        self.router.addRoute(Route(m: .POST, path: p, handlers: c))
    }
    
}