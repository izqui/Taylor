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
    
    init(port p: Int){
        
        _port = p
        super.init()
        self.setup()
    }
    
    func setup(){
        
        _socket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
    }
    
    func startListening(){
        
        var err: NSError?
        _socket!.synchronouslySetDelegate(self)
        if _socket!.acceptOnInterface(nil, port: UInt16(_port), error: &err) {
            
            println("connected port \(_socket!.localPort())")
        
        }
        else if err {
            
            println("Error \(err!)")
        }
        else {
            
            println("wtf")
        }
    }
    
    func socket(socket: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket){
        
        newSocket.readDataWithTimeout(10, tag: 1)
        newSocket.disconnectAfterReading()
    }
    
    func socket(sock: GCDAsyncSocket, didReadData data: NSData, withTag tag: Double){
        
        var d = NSString(data: data, encoding: NSUTF8StringEncoding)
        println("got data \(d)")
        
    }
    
    //- (void)socket:(GCDAsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag;
    func socket(sock: GCDAsyncSocket, didReadPartialDataOfLength length: Int, tag t: Double){
        
        println("partial data \(length)")
    }
    
    //- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err;
    func socketDidDisconnect(sock: GCDAsyncSocket, withError err: NSError){
        
        println("disconnection happened")
    }
    
}