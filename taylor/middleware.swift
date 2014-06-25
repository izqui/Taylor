//
//  middleware.swift
//  Taylor
//
//  Created by Jorge Izquierdo on 23/06/14.
//  Copyright (c) 2014 Jorge Izquierdo. All rights reserved.
//

import Foundation

class Middleware {
    
    class func bodyParser() -> TaylorHandler {
        
        return {
            
            request, response in
            
            if request.bodyString {
                
                if request.headers["Content-Type"] == "application/x-www-form-urlencoded" {
                    
                    var args = request.bodyString!.componentsSeparatedByString("&") as String[]
                    
                    for a in args {
                        
                        var arg = a.componentsSeparatedByString("=") as String[]
                        
                        //Would be nicer changing it to something that checks if element in array exists
                        var val = ""
                        if arg.count > 1 {
                            val = arg[1]
                        }
                        
                        let key = arg[0].stringByReplacingPercentEscapesUsingEncoding(NSASCIIStringEncoding).stringByReplacingOccurrencesOfString("+", withString: " ", options: .LiteralSearch, range: nil)
                        let value = val.stringByReplacingPercentEscapesUsingEncoding(NSASCIIStringEncoding).stringByReplacingOccurrencesOfString("+", withString: " ", options: .LiteralSearch, range: nil)
                        
                        request.body.updateValue(value, forKey: key)
                    }
                }
            }
            
            return (request: request, response: response)
        }
    }
    
    class func staticDirectory(path: String, directory: String) -> TaylorHandler {
        
        let tempComponents = path.componentsSeparatedByString("/")
        var components = String[]()
        
        //We don't care about the first element, which will always be nil since paths are like this: "/something"
        for i in 1..tempComponents.count {
            
            components += tempComponents[i]
        }
        return {
            
            request, response in
            
            if request.pathComponents.count >= components.count && request.method == Request.HTTPMethod.GET{
                
                var j = -1
                // Check if the request matches the path of the static file handler
                for i in 0..components.count {
                    
                    if components[i] != request.pathComponents[i] {
                        
                        // If at some point it doesn't match, just go on with the request handling
                        return (request: request, response: response)
                    }
                    // Means it matched the request
                    j = i
                }
                
                var filePath = directory.stringByExpandingTildeInPath
                
                for k in j+1..request.pathComponents.count {
                    
                    filePath = filePath.stringByAppendingPathComponent(request.pathComponents[k])
                }
                
                let fileManager = NSFileManager.defaultManager()
                
                var isDir:ObjCBool = false
                
                if fileManager.fileExistsAtPath(filePath, isDirectory: &isDir){
                    
                    // In case it is a directory, we look for a index.html file inside
                    if Bool(isDir) && fileManager.fileExistsAtPath(filePath.stringByAppendingPathComponent("index.html")) {
                        
                        filePath = filePath.stringByAppendingPathComponent("index.html")
                    }
                    
                    //TODO: Make it asyncronous
                    var fileData = NSData(contentsOfFile: filePath)
                    response.sendFile(fileData, fileType: FileTypes.get(filePath.pathExtension))
                }
                
                // In case we didn't send any files, 404 it.
                response.sendError(404)
                
            }
            
            // By default, countinue
            return (request: request, response: response)
        }
    }
    
    class func requestLogger() -> TaylorHandler {
        
        return {
            
            request, response in
            
            println("[Taylor] \(request.method.toRaw()) \(request.path)")
            
            return (request: request, response: response)
        }
    }
    
    
}