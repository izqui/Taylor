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

typealias TaylorHandler = (request: Request, response: Response) -> (Request, Response)?

class Route {
    
    let method: Request.HTTPMethod
    let path: String
    
    //inout causing swift to crash with error 254
    let callback: TaylorHandler
  
    init(m: Request.HTTPMethod, path p: String, callback c: TaylorHandler){
        
        method = m
        path = p
        callback = c
    }
}