//
//  router.swift
//  TaylorTest
//
//  Created by Jorge Izquierdo on 19/06/14.
//  Copyright (c) 2014 Jorge Izquierdo. All rights reserved.
//

public class Router: Routable {
    
    public var path: Path
    
    public var beforeHooks: [Routable] = []
    public var handlers: [Routable] = []
    public var afterHooks: [Routable] = []
        
    public convenience init() {
        self.init(pathString: "/*")
    }
    
    public required init(pathString: String) {
        self.path = Path(path: pathString)
    }
    
    public func handleRequest(request: Request, response: Response) -> Callback {
        
        // Call all matching beforeHooks
        let before = beforeHooks.filter { (routable) -> Bool in
            return routable.matchesRequest(request)
        }
        if executeHandlers(before, request: request, response: response) == .Send {
            return .Send
        }
        
        // Call first matching route handler
        var matching: Routable?
        for route in handlers {
            if route.matchesRequest(request) {
                matching = route
                break
            }
        }
        if let matching = matching {
            // Always check result to see if we shoud return early
            let result = matching.handleRequest(request, response: response)
            if result == .Send {
                return result
            }
        }
        
        // If we didn't already return, we know to return .Continue
        return .Continue
    }
    
    public func callAfterHooks(request: Request, response: Response) -> Callback {
        // Call all matching afterHooks
        let after = afterHooks.filter { (routable) -> Bool in
            return routable.matchesRequest(request)
        }
        return executeHandlers(after, request: request, response: response)
    }
    
    
    // Router Methods
    public func addRoute(route: Routable) -> Bool {
        handlers.append(route)
        return true
    }
    
    public func addBeforeHook(hook: Routable) -> Bool {
        beforeHooks.append(hook)
        return true
    }
    
    public func addAfterHook(hook: Routable) -> Bool {
        afterHooks.append(hook)
        return true
    }
}
