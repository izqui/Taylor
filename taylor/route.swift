//
//  route.swift
//  TaylorTest
//
//  Created by Jorge Izquierdo on 19/06/14.
//  Copyright (c) 2014 Jorge Izquierdo. All rights reserved.
//

import Foundation

public class Route {
    
    public let method: Request.HTTPMethod
    public let path: String
    public let handlers: [Taylor.TaylorHandler]

    internal let pathComponents: [Taylor.TaylorPathComponent]
    
    init(m: Request.HTTPMethod, path p: String, handlers s: [Taylor.TaylorHandler]){
        
        self.method = m
        self.handlers = s
        self.path = p
        
        var comps = p.componentsSeparatedByString("/")

        //We don't care about the first element, which will always be nil since paths are like this: "/something"
        self.pathComponents = []
        for i in 1..<comps.count {
            
            //Check if comp is ":something" parameter -> if true, comp = ["", "something"] else comp = ["something"]
            var compArr = comps[i].componentsSeparatedByString(":")
            
            var component: Taylor.TaylorPathComponent = (value:"", isParameter: false)
            
            if compArr.count == 1 {
                
                component.isParameter = false
                component.value = compArr[0]
                
            } else if compArr.count == 2 {
                
                component.isParameter = true
                component.value = compArr[1]
                
            } else {
                
                println("INCORRECT ROUTE SYNTAX for \(self.path)")
                return
            }
            
            self.pathComponents += component
          
        }
    }
}