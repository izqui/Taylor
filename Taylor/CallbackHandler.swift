//
//  CallbackHandler.swift
//  Taylor
//
//  Created by Dan Appel on 11/7/15.
//  Copyright © 2015 Jorge Izquierdo. All rights reserved.
//

class CallbackHandler {
    
    private let handlers: [Handler]
    
    var onSend: Handler?
    var onContinueWithNoHandlersLeft: Handler?

    init(handlers: [Handler]) {
        self.handlers = handlers
    }
    
    func start(request: Request, _ response: Response) {
        // Start handler chain
        handleCallback(.Continue(request, response))
    }
    
    private var requestCount = 0
    private func handleCallback(callback: Callback) {
        switch callback {
        case .Continue(let req, let res):
            
            if self.requestCount < handlers.count {
                // this concerns me...
                let handler = handlers[requestCount]
                requestCount++

                // recursion!
                handler(req, res, handleCallback)
            } else {
                onContinueWithNoHandlersLeft?(req, res, handleCallback)
            }
        case .Send(let req, let res):
            onSend?(req, res, handleCallback)
        }
    }
}
