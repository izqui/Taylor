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
        return executeHandlers(handlers, request: request, response: response)
    }
    
    public func executeHandlers(handlers: [Routable], request: Request, response: Response) -> Callback {
        for routable in handlers {
            // Always check result to see if we should return early
            let result = routable.handleRequest(request, response: response)
            if result == .Send {
                return result
            }
        }
        
        // If we didn't already return, we know to return .Continue
        return .Continue
    }
}

public enum PathComponent {
    case Static(String)
    case Parameter(String)
    case Wildcard // wildcards don't need an associated value (they're always just "*")
}

public struct Path {
    let rawPath: String
    var components: [PathComponent]
    
    public init(path: String) {
        self.rawPath = path
        self.components = []
        
        let comps = path.componentsSeparatedByString("/")
        
        for (i, component) in comps.enumerate() {
            
            // We don't care about the first element,
            // which will always be empty since paths should be like this: "/something"
            if i == 0 {
                continue
            }
            
            // if we don't do this check, getting the first character throws an error
            if component == "" {
                self.components.append(.Static(component))
                continue
            }
            
            // string indexes in Swift are messy...
            let firstChar = String(component[component.startIndex])
            
            switch firstChar {
                
            // if first character is ":", then we have a parameter (ex: ":param")
            case ":":
                // all but first
                let parameter = component.substringFromIndex(component.startIndex.advancedBy(1))
                self.components.append(.Parameter(parameter))
                
            case "*":
                self.components.append(.Wildcard)
                
            default:
                self.components.append(.Static(component))
            }
        }
    }
    
    func matchesRequest(request: Request) -> Bool {
        var parameters = [String : String]()
        
        guard self.components.count == request.pathComponents.count else {
            return false
        }
        
        for (i, pathComponent) in self.components.enumerate() {
            
            switch pathComponent {
                
            case .Static(let componentString):
                guard componentString == request.pathComponents[i] else {
                    return false
                }
                
            case .Parameter(let parameterString):
                parameters[parameterString] = request.pathComponents[i]
                
            case .Wildcard(_):
                continue;
            }
        }
        
        request.parameters = parameters
        return true
    }
}
