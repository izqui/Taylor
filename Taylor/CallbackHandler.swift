//
//  CallbackHandler.swift
//  Taylor
//
//  Created by Dan Appel on 11/7/15.
//  Copyright © 2015 Jorge Izquierdo. All rights reserved.
//

class CallbackHandler {
    
    let server: Server
    let socket: Socket
    init(server: Server, socket: Socket) {
        self.server = server
        self.socket = socket
    }
    
    func start(request: Request, _ response: Response) {
        // Start handler chain
        handleCallback(.Continue(request, response))
    }
    
    var requestCount = 0
    func handleCallback(callback: Callback) {
        switch callback {
        case .Continue(let req, let res):
            if self.requestCount < server.handlers.count {
                let handler = server.handlers[requestCount]
                requestCount++
                // recursion!
                handler(req, res, handleCallback)
            } else {
                // more handlers have been called than there are handlers
                server.notFoundHandler(req, res, handleCallback)
            }
        case .Send(let req, let res):
            let data = res.generateResponse(req.method)
            socket.sendData(data)
            
            // kickstart the hooks
            handleHook(.Continue(req, res))
        }
    }
    
    var hookCount = 0
    func handleHook(callback: Callback) {
        switch callback {
        case .Continue(let req, let res):
            if hookCount < server.postRequestHandlers.count {
                let hook = server.postRequestHandlers[hookCount]
                hookCount++
                // recursion!
                hook(req, res, handleHook)
            }
        case .Send(_, _):
            print("Attempting to send a response twice")
            // maybe do something like this?
            // fatalError("Attempting to send a response twice")
        }
    }
}
