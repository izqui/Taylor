//
//  taylor.swift
//  TaylorTest
//
//  Created by Jorge Izquierdo on 18/06/14.
//  Copyright (c) 2014 Jorge Izquierdo. All rights reserved.
//

import Foundation

public class Taylor: NSObject, GCDAsyncSocketDelegate {
    
    public typealias Handler = (request: TRequest, response: TResponse) -> ()
    internal typealias PathComponent = (value: String, isParameter: Bool)
    
    public enum HTTPMethod: String {
        
        case GET = "GET"
        case POST = "POST"
        case UNDEFINED = "UNDEFINED" // it will never match
    }
    
    public class func NewServer() -> TServer {
        
        return TServer()
    }
    
    public typealias Server = TServer
    public typealias Request = TRequest
    public typealias Response = TResponse
    public typealias Router = TRouter
    public typealias Route = TRoute
    
    public typealias Middleware = TMiddleware
    public typealias FileTypes = TFileTypes
}

public protocol TServerProtocol {
    
    func addHandler(handler: Taylor.Handler)
    
    func startListening(#port: Int, forever: Bool)
    func stopListening()
    
    //Convinience methods
    func get(p: String, callback c: Taylor.Handler...)
    func post(p: String, callback c: Taylor.Handler...)
}

public protocol TRouterProtocol {
    
    func addRoute(route: TRoute) -> Bool
    func handler() -> Taylor.Handler
}

public protocol TRouteProtocol {
    
    init(m: Taylor.HTTPMethod, path p: String, handlers s: [Taylor.Handler])
    
    var method: Taylor.HTTPMethod {get}
    var path: String {get}
    var handlers: [Taylor.Handler] {get}
}

public protocol TRequestProtocol {
    
    var method: Taylor.HTTPMethod {get}
    var path: String {get}
    var headers: [String:String] {get}
    
    var arguments: [String:String] {get}// /name?hello=world -> arguments["hello"]
    var parameters: [String:String] {get}// /name/:something -> parameters["something"]
    
    var body: [String:String] {get set}
    var bodyString: NSString? {get set}
}

public protocol TResponseProtocol {
    
    var statusCode: Int {get set}
    var headers: [String:String] {get set}
    
    var bodyString: String? {get set}
    var body: NSData? {get set}
    
    func send()
    func redirect(url u: String)
    func sendFile(data: NSData, fileType: NSString)
    func sendError(errorCode: Int)
    
    var sent: Bool {get}
}