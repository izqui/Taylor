//
//  route.swift
//  TaylorTest
//
//  Created by Jorge Izquierdo on 19/06/14.
//  Copyright (c) 2014 Jorge Izquierdo. All rights reserved.
//

import Foundation

//Makes the compiler crash
//typealias TaylorHandler = (inout request: Request, inout response: Response) -> (ok: Bool)

typealias TaylorTuple = (request: Request, response: Response)
typealias TaylorHandler = TaylorTuple -> TaylorTuple?

class Route {
    
    let method: Request.HTTPMethod
    let path: String
    
    //inout causing swift to crash with error 254
    let handlers: TaylorHandler[]
  
    init(m: Request.HTTPMethod, path p: String, handlers s: TaylorHandler[]){
        
        self.method = m
        self.path = p
        self.handlers = s
    }
}