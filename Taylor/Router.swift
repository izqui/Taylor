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
    
    public var notFoundHandler: Handler = {
        req, res in
        res.setError(404)
        return .Send(req, res)
    }
    
    init() {
        self.path = Path(path: "")
    }
    
    public func handleRequest(request: Request, response: Response) -> Callback {
        
        // Call all matching beforeHooks
        let before = beforeHooks.filter { (routable) -> Bool in
            return routable.matchesRequest(request)
        }
        for routable in before {
            // Always check result to see if we shoud return early
            let result = routable.handleRequest(request, response: response)
            if case .Send(_, _) = result {
                return result
            }
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
            if case .Send(_, _) = result {
                return result
            }
        }
        
        // If we didn't already return, we know to return .Continue
        return .Continue(request, response)
    }
    
    public func callAfterHooks(request: Request, response: Response) -> Callback {
        // Call all matching afterHooks
        let after = afterHooks.filter { (routable) -> Bool in
            return routable.matchesRequest(request)
        }
        for routable in after {
            // Always check result to see if we shoud return early
            let result = routable.handleRequest(request, response: response)
            if case .Send(_, _) = result {
                return result
            }
        }
        
        // If we didn't already return, we know to return .Continue
        return .Continue(request, response)
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
