//
//  taylor.swift
//  TaylorTest
//
//  Created by Jorge Izquierdo on 18/06/14.
//  Copyright (c) 2014 Jorge Izquierdo. All rights reserved.
//

import Foundation

public class Taylor: NSObject, GCDAsyncSocketDelegate {
    
    public enum HTTPMethod: String {
        
        case GET = "GET"
        case POST = "POST"
        case UNDEFINED = "UNDEFINED" // it will never match
    }

    public typealias TaylorHandler = TaylorHandlerComponents -> ()
    public typealias TaylorHandlerComponents = (request: Request, response: Response)
    internal typealias TaylorPathComponent = (value: String, isParameter: Bool)
    
    /*public class func NewServer() {
        
        var a = Server()
    }*/
}

public protocol ServerProtocol {
    
    func startListening(#port: Int, forever: Bool)
    func stopListening()
    
    func addHandler(handler: Taylor.TaylorHandler)
}

public protocol RouteProtocol {
    
    init(m: Taylor.HTTPMethod, path p: String, handlers s: [Taylor.TaylorHandler])
    
    var method: Taylor.HTTPMethod {get}
    var path: String {get}
    var handlers: [Taylor.TaylorHandler] {get}
    
}

public protocol RouterProtocol {
    
    func addRoute(route: Route) -> Bool
    func handler() -> Taylor.TaylorHandler 
    
}

@objc public protocol RequestProtocol {
    
    var path: String { get set }
    var headers: Dictionary<String, String> {get}
    
    var arguments: Dictionary<String, String> {get}// /name?hello=world -> arguments["hello"]
    var parameters: Dictionary<String, String> {get}// /name/:something -> parameters["something"]
    
    var body: Dictionary<String, String> {get}
    
    optional var bodyString: NSString {get set}
}

@objc public protocol ResponseProtocol {
    
    var statusCode: Int {get set}
    var headers: Dictionary<String, String> {get set}
    optional var body: NSData {get set}
    
    func send()
    var sent: Bool {get}
}

public protocol MiddlewareProtocol {
    
    class func bodyParser() -> Taylor.TaylorHandler
    class func staticDirectory(path: String, directory: String) -> Taylor.TaylorHandler
    class func requestLogger() -> Taylor.TaylorHandler
}