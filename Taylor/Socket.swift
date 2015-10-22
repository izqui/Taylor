//
//  Socket.swift
//  Taylor
//
//  Created by Jorge Izquierdo on 9/14/15.
//  Copyright © 2015 Jorge Izquierdo. All rights reserved.
//

typealias ReceivedRequestCallback = ((Request, Socket) -> Bool)

enum SocketErrors: ErrorType {
    case ListenError
    case PortUsedError
}

protocol SocketServer {

    func startOnPort(p: Int) throws
    func disconnect()
    
    var receivedRequestCallback: ReceivedRequestCallback? { get set }
}

protocol Socket {
    func sendData(data: NSData)
}

// Mark: SwiftSocket Implementation of the Socket and SocketServer protocol

#if os(OSX) // Change for Linux platform when ready
    
import ARISockets

struct SwiftSocket: Socket {
    
    let socket: ActiveSocketIPv4
    
    func sendData(data: NSData) {
        
        socket.write(dispatch_data_create(data.bytes, data.length, dispatch_get_main_queue(), nil))
        socket.close()
    }
}

class SwiftSocketServer: SocketServer {
    
    var socket: PassiveSocketIPv4!
    
    var receivedRequestCallback: ReceivedRequestCallback?
    
    func startOnPort(p: Int) throws {
        
        guard let socket = PassiveSocketIPv4(address: sockaddr_in(port: p)) else { throw SocketErrors.ListenError }
        socket.listen(dispatch_get_global_queue(0, 0)) {
            socket in
            
            socket.onRead {
                newsock, length in
                
                socket.isNonBlocking = true
                
                var initialData: NSData?
                var bodyData: NSData?
                
                let (size, data, _) = newsock.read()
                
                if size > 0 {
                    initialData = NSData(bytes: data, length: size)
                    let string = String(data: initialData!, encoding: NSUTF8StringEncoding)
                    print("Raw: \(string)")
                }
                
                if let initialData = initialData {
                    let request = Request(headerData: initialData)
                    
                    // Initial data may not contain body
                    // Check if request contains a body, and that it hasn't been read yet
                    if  let lengthString = request.headers["Content-Length"],
                        let length = UInt(lengthString) where length > 0 && request.bodyString == nil {
                            
                            let (bSize, bData, _) = newsock.read()
                            
                            if bSize > 0 {
                                bodyData = NSData(bytes: bData, length: bSize)
                                request.parseBodyData(bodyData)
                            }
                    }
                    
                    self.receivedRequestCallback?(request, SwiftSocket(socket: socket))
                }
            }
        }
        
        self.socket = socket
    }
    
    func disconnect() {
        self.socket.close()
    }
}

#else
// Mark: Cocoa Async Implementation of the Socket and SocketServer protocol
    
import CocoaAsyncSocket

class AsyncSocket: GCDAsyncSocket, Socket {
    
    var request: Request?
    
    func sendData(data: NSData) {
        self.writeData(data, withTimeout: 10, tag: 1)
        self.disconnectAfterWriting()
    }
}

class AsyncSocketServer: GCDAsyncSocketDelegate, SocketServer {
    
    static var sharedSocket = AsyncSocketServer() //I'm really sorry about this and really looking for a better solution. Please sumbit an issue/PR. Reason: https://github.com/robbiehanson/CocoaAsyncSocket/issues/248
    let socket = AsyncSocket()
    var sockets: [AsyncSocket] = []
    
    var receivedRequestCallback: ReceivedRequestCallback?
    func startOnPort(p: Int) throws {
        
        socket.setDelegate(AsyncSocketServer.sharedSocket, delegateQueue: dispatch_get_main_queue())
        AsyncSocketServer.sharedSocket.receivedRequestCallback = self.receivedRequestCallback
        try socket.acceptOnPort(UInt16(p))
    }
    
    func disconnect() {
        socket.disconnect()
    }
    
    // GCDAsyncSocketDelegate methods
    @objc func socket(socket: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket){
        
        if let socket = newSocket as? AsyncSocket {
            sockets.append(socket)
            
            // Always stop at the end of the request headers to handle cases where body may not exist yet
            let responseData = "\r\n\r\n".dataUsingEncoding(NSASCIIStringEncoding)
            newSocket.readDataToData(responseData, withTimeout: 10, tag: 1)
        }
    }
    
    @objc func socket(sock: GCDAsyncSocket!, didReadData data: NSData!, withTag tag: Int) {
        
        guard let socket = sock as? AsyncSocket else {
            return
        }
        
        if tag == 1 { // Header Data
            socket.request = Request(headerData: data)
            if  let lengthString = socket.request?.headers["Content-Length"],
                let length = UInt(lengthString) where length > 0 {
                    
                    sock.readDataToLength(length, withTimeout: 3, tag: 2)
            }
            else {
                self.receivedRequestCallback?(socket.request!, socket)
            }
        }
        else if tag == 2 { // Body Data
            socket.request!.parseBodyData(data)
            self.receivedRequestCallback?(socket.request!, socket)
        }
    }
    
    @objc func socketDidDisconnect(sock: GCDAsyncSocket, withError err: NSError){
        if let socket = sock as? AsyncSocket, let i = sockets.indexOf(socket) {
            sockets.removeAtIndex(i)
        }
    }
    
    @objc func newSocketQueueForConnectionFromAddress(address: NSData!, onSocket sock: GCDAsyncSocket!) -> dispatch_queue_t! {
        
        return dispatch_get_main_queue() //Maybe change to a background queue?
    }
    
    @objc func socketDidCloseReadStream(sock: GCDAsyncSocket!) {
        
    }
}

#endif
