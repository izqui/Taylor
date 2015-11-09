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
    
    func execute(request: Request, _ response: Response) -> Callback {
        
        var request = request
        var response = response
        for (i, handler) in handlers.enumerate() {
            
            let result = handler(request, response)
            
            switch result {
            case .Continue(let req, let res):
                request = req
                response = res
                
                if i == (handlers.count - 1) {
                    
                    guard let result = onContinueWithNoHandlersLeft?(request, response) else {
                        // usually means that no actual response
                        // is being sent (ex: hooks)
                        return .Continue(request, response)
                    }
                    
                    // usually a .Send with a 404 page or something
                    return result
                }
                
            case .Send(let req, let res):
                return .Send(req, res)
            }
        }
        
        if handlers.count == 0 {
            return .Continue(request, response)
        }
        
        // if it hit this, something went wrong
        fatalError()
    }
}
