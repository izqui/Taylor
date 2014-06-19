//
//  route.swift
//  TaylorTest
//
//  Created by Jorge Izquierdo on 19/06/14.
//  Copyright (c) 2014 Jorge Izquierdo. All rights reserved.
//

import Foundation

class Route {
    
    let method: Request.HTTPMethod
    let path: String
    
    //inout causing swift to crash with error 254
    let callback: (request: Request, response: Response) -> (ok: Bool)
  
    init(m: Request.HTTPMethod, path p: String, callback c: (request: Request, response: Response) -> (ok: Bool)){
        
        method = m
        path = p
        callback = c
    }
}