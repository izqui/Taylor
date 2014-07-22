//
//  taylor.swift
//  TaylorTest
//
//  Created by Jorge Izquierdo on 18/06/14.
//  Copyright (c) 2014 Jorge Izquierdo. All rights reserved.
//

import Foundation

public class Taylor: NSObject, GCDAsyncSocketDelegate {
    
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