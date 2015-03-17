//
//  taylor.swift
//  TaylorTest
//
//  Created by Jorge Izquierdo on 18/06/14.
//  Copyright (c) 2014 Jorge Izquierdo. All rights reserved.
//

import Foundation

public enum Callback {
    case Continue(Request, Response)
    case Send(Request, Response)
}

public typealias Handler = (Request, Response, (Callback) -> ()) -> ()
internal typealias PathComponent = (value: String, isParameter: Bool)

public enum Result {
    case Success
    case Error(NSError)
}

public enum HTTPMethod: String {
        
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case UNDEFINED = "UNDEFINED" // it will never match
}
    