//
//  request.swift
//  TaylorTest
//
//  Created by Jorge Izquierdo on 19/06/14.
//  Copyright (c) 2014 Jorge Izquierdo. All rights reserved.
//

import Foundation

public class Request {
    
    public var path: String {

    didSet {
        
        var comps = self.path.componentsSeparatedByString("/")
        
        //We don't care about the first element, which will always be nil since paths are like this: "/something"
        for i in 1..<comps.count {
            
            self.pathComponents.append(comps[i])
        }
    }
    }
    public var pathComponents: [String] = [String]()
    
    public var arguments: Dictionary<String, String> = Dictionary<String, String>() // ?hello=world -> arguments["hello"]
    public var parameters: Dictionary<String, String> = Dictionary<String, String>() // /:something -> parameters["something"]
    
    public var method: Taylor.HTTPMethod = .UNDEFINED
    public var headers: Dictionary<String, String> = Dictionary<String, String>()
    
    //var bodyData: NSData?
    public var bodyString: NSString?
    public var body: Dictionary<String, String> = Dictionary<String, String>()
    
    internal var startTime: Double = CACurrentMediaTime()
    var _protocol: String?
    
    convenience init(){
        
        self.init(data: nil)
    }

    init(data d: NSData?){
        
        self.path = String()
        //Parsing data from socket to build a HTTP request
        if d != nil {
            
            self.parseRequest(d!)
        }
    }
    
    private func parseRequest(d: NSData){
        
        //TODO: Parse data line by line, so if body content is not UTF8 encoded, this doesn't crash
        var string = NSString(data: d, encoding: NSUTF8StringEncoding)
        var http: [String] = string!.componentsSeparatedByString("\r\n") as! [String]
        
        //Parse method
        if http.count > 0 {

            // The delimiter can be any number of blank spaces
            var startLineArr: [String] = split(http[0], maxSplit: Int.max, allowEmptySlices: false) { $0 == " "}
            
            if startLineArr.count > 0 {
                
                if let m = Taylor.HTTPMethod(rawValue: startLineArr[0]) {
                    
                    self.method = m
                }
            }
            
            //Parse URL
            if startLineArr.count > 1 {
                
                var url = startLineArr[1]
                var urlElements: [String] = url.componentsSeparatedByString("?") as [String]
                
                self.path = urlElements[0]
                
                if urlElements.count == 2 {
                    
                    var args = urlElements[1].componentsSeparatedByString("&") as [String]
                    
                    for a in args {
                        
                        var arg = a.componentsSeparatedByString("=") as [String]
                        
                        //Would be nicer changing it to something that checks if element in array exists
                        var value = ""
                        if arg.count > 1 {
                            value = arg[1]
                        }
                        
                        // Adding the values removing the %20 bullshit and stuff
                        self.arguments.updateValue(value.stringByReplacingPercentEscapesUsingEncoding(NSASCIIStringEncoding)!, forKey: arg[0].stringByReplacingPercentEscapesUsingEncoding(NSASCIIStringEncoding)!)
                    }
                }
            }
            
            //TODO: Parse HTTP version
            if startLineArr.count > 2{
                
                _protocol = startLineArr[2]
            }
        }
        
        //Parse Headers
        var i = 0
    
        while ++i < http.count {
            
            var content = http[i]
            
            if content == "" {
                // This newline means headers have ended and body started (New line already got parsed ("\r\n"))
                break
            }
            var header = content.componentsSeparatedByString(": ") as [String]
            if header.count == 2 {
                
                self.headers.updateValue(header[1], forKey: header[0])
            }
        }
        
        if i < http.count && (self.method == Taylor.HTTPMethod.POST || false) { // Add other methods that support body data
            
            
            var str = NSMutableString()
            while ++i < http.count {
                
                str.appendString("\(http[i])\n")
            }
            
            self.bodyString = str
        }
    }
}
