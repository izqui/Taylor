//
//  Routable.swift
//  Taylor
//
//  Created by Kevin Sullivan on 11/8/15.
//  Copyright © 2015 Jorge Izquierdo. All rights reserved.
//

import Foundation

public protocol Routable {
    var handlers: [Routable] { get }
    var path: Path { get }
    
    func matchesRequest(request: Request) -> Bool
    func handleRequest(request: Request, response: Response) -> Callback
    func executeHandlers(handlers: [Routable], request: Request, response: Response) -> Callback
}

extension Routable {
    public func matchesRequest(request: Request) -> Bool {
        return path.matchesRequest(request)
    }
    
    public func handleRequest(request: Request, response: Response) -> Callback {
        let toHandle = handlers.filter { (routable) -> Bool in
            return routable.matchesRequest(request)
        }
        return executeHandlers(toHandle, request: request, response: response)
    }
    
    public func executeHandlers(handlers: [Routable], request: Request, response: Response) -> Callback {
        for routable in handlers {
            // Always check result to see if we shoud return early
            let result = routable.handleRequest(request, response: response)
            if case .Send(_, _) = result {
                return result
            }
        }
        
        // If we didn't already return, we know to return .Continue
        return .Continue(request, response)
    }
}


// Used for Routables that will never call other Routables, like Route and Middleware
public protocol RoutableEndPoint {
    var handlerClosures: [Handler] { get }
    func executeHandlerClosures(forRequest request: Request, response: Response) -> Callback
}

extension RoutableEndPoint {
    public func executeHandlerClosures(forRequest request: Request, response: Response) -> Callback {
        for handler in handlerClosures {
            // Always check result to see if we shoud return early
            let result = handler(request, response)
            if case .Send(_, _) = result {
                return result
            }
        }
        
        // If we didn't already return, we know to return .Continue
        return .Continue(request, response)
    }
}

public enum PathComponent {
    case Static(String)
    case Parameter(String)
    // case Wildcard(String)
}

public struct Path {
    let rawPath: String
    var components: [PathComponent]
    
    init(path: String) {
        self.rawPath = path
        self.components = []
        
        var comps = path.componentsSeparatedByString("/")
        
        //We don't care about the first element, which will always be nil since paths are like this: "/something"
        for i in 1..<comps.count {
            
            //Check if comp is ":something" parameter -> if true, comp = ["", "something"] else comp = ["something"]
            var compArr = comps[i].componentsSeparatedByString(":")
            
            if compArr.count == 1 {
                self.components.append(.Static(compArr[0]))
                
            } else if compArr.count == 2 {
                self.components.append(.Parameter(compArr[1]))
            } else {
                print("INCORRECT ROUTE SYNTAX for \(path)")
                return
            }
        }
    }
    
    func matchesRequest(request: Request) -> Bool {
        var parameters: [String : String] = [:]
        let componentCount = self.components.count
        
        if componentCount == request.pathComponents.count {
            
            for i in 0..<componentCount {
                let pathComponent = self.components[i]
                
                switch pathComponent {
                case .Static(let componentString):
                    if componentString != request.pathComponents[i] {
                        return false
                    }
                case .Parameter(let parameterString):
                    parameters[parameterString] = request.pathComponents[i]
                }
            }
            
            request.parameters = parameters
            return true
        }
        
        return false
    }
}
