//
//  taylor.swift
//  TaylorTest
//
//  Created by Jorge Izquierdo on 18/06/14.
//  Copyright (c) 2014 Jorge Izquierdo. All rights reserved.
//

import Foundation

class Taylor: NSObject, GCDAsyncSocketDelegate {
    
    let _port: Int
    var _socket: GCDAsyncSocket?
    
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
    
    func socket(socket: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket){
        
        newSocket.readDataWithTimeout(10, tag: 1)
        
    }
    
    func socket(sock: GCDAsyncSocket, didReadData data: NSData, withTag tag: Double){
        
        var request = Request(data: data)
        var response = Response(socket: sock)
        
        if self.router.handleRequest(request, response: response) {
            
            sock.disconnectAfterWriting()
        }
    }
    
    /*
    //- (void)socket:(GCDAsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag;
    func socket(sock: GCDAsyncSocket, didReadPartialDataOfLength length: Int, tag t: Double){
  
    }*/
    
    //- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err;
    func socketDidDisconnect(sock: GCDAsyncSocket, withError err: NSError){
        
        println("disconnection happened")
    }
    
    
    //Convenience methods
    func get(p: String, callback c: (request: Request, response: Response) -> (ok: Bool)) {
        
        self.router.addRoute(Route(m: .GET, path: p, callback: c))
    }
    
}