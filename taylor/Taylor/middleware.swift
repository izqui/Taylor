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
    
    public class func staticDirectory(path: String, bundle: NSBundle) -> Handler {
        return staticDirectory(path, directory: bundle.resourcePath!)
    }
    
    public class func staticDirectory(path: String, directory: String) -> Handler {
        let dirComponents = path.taylor_pathComponents
        
        return { request, response, callback in
            let requestComponents = request.path.taylor_pathComponents
            
            if request.method != .GET || !self.matchPaths(requestPath: requestComponents, inPath: dirComponents) {
                callback(.Continue(request, response))
                return
            }
            
            let fileComponents = requestComponents[dirComponents.count..<requestComponents.count] // matched comps after dirComponents
            println(fileComponents)
            var filePath = directory.stringByExpandingTildeInPath.stringByAppendingPathComponent(join("/", fileComponents))
            println(filePath)
            
            let fileManager = NSFileManager.defaultManager()
            var isDir: ObjCBool = false
            
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
    }
    
    private class func matchPaths(#requestPath: [String], inPath dirPath: [String]) -> Bool {
        return requestPath.count >= dirPath.count && equal(requestPath[0..<dirPath.count], dirPath)
    }


    public class func requestLogger(printer: ((String) -> ())) -> Handler {
    
        return {
            request, response, callback in
        
            let time = NSString(format: "%.02f", (CACurrentMediaTime()-request.startTime)*1000)
            let text = "\(response.statusCode) \(request.method.rawValue) \(request.path) \(time)ms"
        
            printer(text)
            callback(.Continue(request, response))
        }
    }
}