//
//  Taylor_Tests.swift
//  Taylor-Tests
//
//  Created by Jorge Izquierdo on 26/06/14.
//  Copyright (c) 2014 Jorge Izquierdo. All rights reserved.
//

import XCTest
import Taylor

class Taylor_Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    /*
    func testRequestHandler() {
        // This is an example of a functional test case.
        
        var taylor = Taylor.NewServer()

        taylor.addHandler {
            
            request, response in
            response.bodyString = "Hey"
        }
        
        taylor.handleRequest(TRequest(), response: TResponse()) {
            
            XCTAssertEqual(true, "hey")
        }
        
        taylor.startListening(port:3000, forever: false)
        
    }
    
    func testRequestParsing() {
        
        let string = "POST /hello?name=jorge HTTP/1.1\r\nHost: localhost:3003\r\nHeader2: hahaha  ssss\r\nHeader3: hehehe\r\n\r\nWhatever"
        let request = TRequest(data: string.dataUsingEncoding(NSUTF8StringEncoding))
        
        XCTAssertEqual(request.method, Taylor.HTTPMethod.POST, "Method parsing")
        XCTAssertEqual(request.path, "/hello", "Path parsing")
        XCTAssertEqual(request.headers.count, 3, "Header parsing")
        XCTAssertEqual(request.arguments["name"]!, "jorge", "Arg parsing")
    }

    func testRequestParsingWithMultipleSP() {

        let string = "GET   /write?space=name  HTTP/1.1\r\nHost: localhost:1989\r\nHeader2: It's gonna go down in flames\r\n\r\ndaydream"
        let request = TRequest(data: string.dataUsingEncoding(NSUTF8StringEncoding))

        XCTAssertEqual(request.method, Taylor.HTTPMethod.GET, "Method parsing")
        XCTAssertEqual(request.path, "/write", "Path parsing")
        XCTAssertEqual(request.headers.count, 2, "Header parsing")
        XCTAssertEqual(request.arguments["space"]!, "name", "Arg parsing")
    }
    
    func testBodyParsing() {
        
        let string = "POST /hello?name=jorge HTTP/1.1\r\nHost: localhost:3003\r\nContent-Type: application/x-www-form-urlencoded\r\n\r\nhello=hi&goodbye=bye"
        let request = TRequest(data: string.dataUsingEncoding(NSUTF8StringEncoding))
        
        var bodyParser = TMiddleware.bodyParser()
        XCTAssert(true, "Crash")
    
        bodyParser(request: request, response: TResponse())
        
        var body = request.body
        
        if let a = body["hello"] {

            XCTAssertEqual(a, "hi", "Fuck")
            
        } else {
            
            XCTAssert(true, "Crash")
        }
    }
    
    func testRouter() {
        
        let router = TRouter()
        let handler: Taylor.Handler = {
            
            request, response in
            
            response.sent = true
        }
        
        let route = TRoute(m: .GET, path: "/hello/:whatever/jey", handlers:[handler])
        router.addRoute(route)
        
        let request = TRequest()
        request.method = .GET
        request.path = "/hello/hshshshs/jey"
        
        let response = TResponse()
        
        let rHandler: Taylor.Handler = router.handler()

        rHandler(request:request, response: response)
        XCTAssert(response.sent, "TRequest handled")
        
    }
    
    func testResponseGeneration() {
        
        let response = TResponse()
        response.bodyString = "Hello"
        
        let s = NSString(data: response.generateResponse(), encoding: NSUTF8StringEncoding)
    
        XCTAssertEqual(String(s!), "HTTP/1.1 200 OK\r\nContent-Length: 5\r\nContent-Type: text/plain\r\n\r\nHello", "Generates")
    }
    
    func testFileTypes() {
        
        XCTAssertEqual(Taylor.FileTypes.get("html"), "text/html", "Type")
        XCTAssertEqual(Taylor.FileTypes.get("json"), "application/json", "Type")
    }*/
}
