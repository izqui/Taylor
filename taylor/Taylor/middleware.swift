//
//  middleware.swift
//  Taylor
//
//  Created by Jorge Izquierdo on 23/06/14.
//  Copyright (c) 2014 Jorge Izquierdo. All rights reserved.
//

import Foundation

public class Middleware {
    
    public class func bodyParser() -> Handler {
        
        return {
            
            request, response, callback in
            
            if request.bodyString != nil && request.headers["Content-Type"] != nil {
                
                var h: NSString = request.headers["Content-Type"]! as NSString
                
                var notfound: Bool = (Int(NSIntegerMax) == h.rangeOfString("application/x-www-form-urlencoded").location)
                
                if !notfound {
                    
                    if let b = request.bodyString {
                        
                        var args = b.componentsSeparatedByString("&") as! [String]
                        
                        for a in args {
                            
                            var arg = a.componentsSeparatedByString("=") as [String]
                            
                            //Would be nicer changing it to something that checks if element in array exists
                            var val = ""
                            if arg.count > 1 {
                                val = arg[1]
                            }
                            
                            let key = arg[0].stringByReplacingPercentEscapesUsingEncoding(NSASCIIStringEncoding)!.stringByReplacingOccurrencesOfString("+", withString: " ", options: .LiteralSearch, range: nil) as String
                            let value = val.stringByReplacingPercentEscapesUsingEncoding(NSASCIIStringEncoding)!.stringByReplacingOccurrencesOfString("+", withString: " ", options: .LiteralSearch, range: nil) as String
                            
                            request.body[key] = value.stringByReplacingOccurrencesOfString("\n", withString: "", options: .LiteralSearch, range: nil)
                        }
                    }
                }
            }
            callback(.Continue(request, response))
            return
        }
    }
    
    public class func staticDirectory(path: String, directory: String? = nil, bundle: NSBundle? = nil) -> Handler {
        
        let tempComponents = path.componentsSeparatedByString("/")
        var components = [String]()
        
        //We don't care about the first element, which will always be nil since paths are like this: "/something"
        for i in 1..<tempComponents.count {
            
            components.append(tempComponents[i])
            
        }
        
        return {
            
            request, response, callback in
            
            var comps = request.path.componentsSeparatedByString("/")
            
            
            //We don't care about the first element, which will always be nil since paths are like this: "/something"
            var pathComponents: [String] = []
            for i in 1..<comps.count {
                
                pathComponents.append(comps[i])
            }
            
            
            if request.method == Taylor.HTTPMethod.GET && pathComponents.count >= components.count {
                
                var j = -1
                // Check if the request matches the path of the static file handler
                for i in 0..<components.count {
                    
                    if components[i] != pathComponents[i] {
                        
                        // If at some point it doesn't match, just go on with the request handling
                        callback(.Continue(request, response))
                        return
                    }
                    // Means it matched the request
                    j = i
                }
                
                if let b = bundle {
                    
                    let last = pathComponents.removeLast()
                    pathComponents.removeRange(0..<components.count)
                    response.setFile(b.URLForResource(last.lastPathComponent.stringByDeletingPathExtension, withExtension: last.pathExtension, subdirectory:NSString.pathWithComponents(pathComponents)))
                    callback(.Send(request, response))
                    
                } else if let dir = directory {
                    var filePath = dir.stringByExpandingTildeInPath
                    
                    for k in j+1..<pathComponents.count {
                        
                        filePath = filePath.stringByAppendingPathComponent(pathComponents[k])
                    }
                    
                    println(filePath)
                    let fileManager = NSFileManager.defaultManager()
                    
                    var isDir:ObjCBool = false
                    
                    if fileManager.fileExistsAtPath(filePath, isDirectory: &isDir){
                        
                        // In case it is a directory, we look for a index.html file inside
                        if Bool(isDir) && fileManager.fileExistsAtPath(filePath.stringByAppendingPathComponent("index.html")) {
                            
                            filePath = filePath.stringByAppendingPathComponent("index.html")
                        }
                        
                        response.setFile(NSURL(fileURLWithPath: filePath))
                        callback(.Send(request, response))
                        
                    } else {
                        callback(.Continue(request, response))
                    }
                    
                }
            } else {
                
                callback(.Continue(request, response))
            }
        }
    }


public class func requestLogger(printer: ((String) -> ())? = nil) -> Handler {
    
    return {
        
        request, response, callback in
        
        let time = NSString(format: "%.02f", (CACurrentMediaTime()-request.startTime)*1000)
        let text = "\(response.statusCode) \(request.method.rawValue) \(request.path) \(time)ms"
        
        (printer != nil ? printer : println)!(text)
        callback(.Continue(request, response))
    }
}
}