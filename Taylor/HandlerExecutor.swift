//
//  CallbackHandler.swift
//  Taylor
//
//  Created by Dan Appel on 11/7/15.
//  Copyright © 2015 Jorge Izquierdo. All rights reserved.
//

class HandlerExecutor {

    private let handlers: [Handler]
    var onContinueWithNoHandlersLeft: Handler?
    
    init(handlers: [Handler]) {
        self.handlers = handlers
    }
    
    func execute(request: Request, _ response: Response) -> (Request, Response) {
        // Start handler chain
        return handleCallback(.Continue(request, response))
    }
    
    private var requestCount = 0
    private func handleCallback(callback: Callback) -> Callback {//-> Callback {
        switch callback {
        case .Continue(let req, let res):
            
            if self.requestCount < handlers.count {
                // this concerns me...
                let handler = handlers[requestCount]
                requestCount++
                
                // recursion!
                let result = handler(req, res)
                return handleCallback(result)
            } else {
                
                // usually means that it just needs result of the handlers (ex: hooks)
                guard let result = onContinueWithNoHandlersLeft?(req, res) else {
                    return .Continue(req, res)
                }
                
                // usually just a .Send with a 404 not found page or something
                return handleCallback(result)

            }
        case .Send(let req, let res):
            
            // give the data back for processing (usually ends up in a socket)
            return .Send(req, res)
        }
    }
}
