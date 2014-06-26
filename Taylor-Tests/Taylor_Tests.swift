//
//  Taylor_Tests.swift
//  Taylor-Tests
//
//  Created by Jorge Izquierdo on 26/06/14.
//  Copyright (c) 2014 Jorge Izquierdo. All rights reserved.
//

import XCTest

class Taylor_Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRequestHandler() {
        // This is an example of a functional test case.
        
        var taylor = Taylor(port: 3000)
        
        taylor.use {
            
            request, response in
            return nil
        }
        
        taylor.handleRequest(Request(), response: Response()) {
            
            XCTAssert(true, "Taylor middleware handles requests")
        }
        
        taylor.startListening(forever: false)
        
    }
    
    func testRequestParsing() {
        
        let string = "POST /hello?name=jorge HTTP/1.1\r\nHost: localhost:3003\r\nHeader2: hahaha  ssss\r\nHeader3: hehehe\r\n\r\nWhatever"
        let request = Request(data: string.dataUsingEncoding(NSUTF8StringEncoding))
        
        println(request.path)
        println(request.headers)
        
        XCTAssertEqual(request.method, Request.HTTPMethod.POST, "Method parsing")
        XCTAssertEqual(request.path, "/hello", "Path parsing")
        XCTAssertEqual(request.headers.count, 3, "Header parsing")
        
        let body: NSString = (request.bodyString as NSString)
        
        //XCTAssertEqual(body.containsString("Whatever"), true, "Body")
    }
    
}
