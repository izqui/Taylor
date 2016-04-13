//
//  middleware.swift
//  Taylor
//
//  Created by Jorge Izquierdo on 23/06/14.
//  Copyright (c) 2014 Jorge Izquierdo. All rights reserved.
//

import Foundation

public class Middleware: Routable {
    
    public let path: Path
    public var handlers: [Routable] = []
    
    public required init(path p: String, handlers s: [Handler]){
        for handler in s {
            self.handlers.append(RouteHandler(handler: handler))
        }
        self.path = Path(path: p)
    }
    
    // This can be removed once wildcard routes are implemented
    public func matchesRequest(request: Request) -> Bool {
        return true
    }
    
    
}

extension Middleware {
    public class func bodyParser() -> Handler {
        return { request, response in
            
            if request.bodyString != nil && request.headers["Content-Type"] != nil {
                
                let h = request.headers["Content-Type"]!
                
                if h.rangeOfString("application/x-www-form-urlencoded") != nil {
                    
                    if let b = request.bodyString {
                        
                        let args = b.componentsSeparatedByString("&") as [String]
                        
                        for a in args {
                            
                            var arg = a.componentsSeparatedByString("=") as [String]
                            
                            //Would be nicer changing it to something that checks if element in array exists
                            var val = ""
                            if arg.count > 1 {
                                val = arg[1]
                            }
                            
                            let key = arg[0].stringByRemovingPercentEncoding!.stringByReplacingOccurrencesOfString("+", withString: " ", options: .LiteralSearch, range: nil)
                            let value = val.stringByRemovingPercentEncoding!.stringByReplacingOccurrencesOfString("+", withString: " ", options: .LiteralSearch, range: nil)
                            
                            request.body[key] = value.stringByReplacingOccurrencesOfString("\n", withString: "", options: .LiteralSearch, range: nil)
                        }
                    }
                }
            }
            
            return .Continue
        }
    }
    
    public class func staticDirectory(path: String, bundle: NSBundle) -> Handler {
        return staticDirectory(path, directory: bundle.resourcePath!)
    }
    
    public class func staticDirectory(path: String, directory: String) -> Handler {
        let dirComponents = path.taylor_pathComponents
        
        return { request, response in
            let requestComponents = request.path.taylor_pathComponents
            
            if request.method != .GET || !self.matchPaths(requestPath: requestComponents, inPath: dirComponents) {
                return .Continue
            }
            
            let fileComponents = requestComponents[dirComponents.count..<requestComponents.count] // matched comps after dirComponents
            var filePath = directory.NS.stringByExpandingTildeInPath.NS.stringByAppendingPathComponent(fileComponents.joinWithSeparator("/"))
            
            let fileManager = NSFileManager.defaultManager()
            var isDir: ObjCBool = false
            
            if fileManager.fileExistsAtPath(filePath, isDirectory: &isDir){
                // In case it is a directory, we look for a index.html file inside
                if Bool(isDir) && fileManager.fileExistsAtPath(filePath.NS.stringByAppendingPathComponent("index.html")) {
                    filePath = filePath.NS.stringByAppendingPathComponent("index.html")
                }
                
                response.setFile(NSURL(fileURLWithPath: filePath))
                return .Send
            } else {
                return .Continue
            }
        }
    }
    
    private class func matchPaths(requestPath requestPath: [String], inPath dirPath: [String]) -> Bool {
        return requestPath.count >= dirPath.count && requestPath[0..<dirPath.count].elementsEqual(dirPath)
    }
    
    
    public class func requestLogger(printer: ((String) -> ())) -> Handler {
        
        return { request, response in
            
            let time = String(format: "%.02f", NSDate().timeIntervalSinceDate(request.startTime) * 1000)
            let text = "\(response.statusCode) \(request.method.rawValue) \(request.path) \(time)ms"
            
            printer(text)
            return .Continue
        }
    }
}
