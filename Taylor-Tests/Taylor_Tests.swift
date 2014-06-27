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
        
        XCTAssertEqual(request.method, Request.HTTPMethod.POST, "Method parsing")
        XCTAssertEqual(request.path, "/hello", "Path parsing")
        XCTAssertEqual(request.headers.count, 3, "Header parsing")
        XCTAssertEqual(request.arguments["name"]!, "jorge", "Arg parsing")
    }
    
    func testBodyParsing() {
        
        let string = "POST /hello?name=jorge HTTP/1.1\r\nHost: localhost:3003\r\nContent-Type: application/x-www-form-urlencoded\r\n\r\nhello=hi&goodbye=bye"
        let request = Request(data: string.dataUsingEncoding(NSUTF8StringEncoding))
        
        var bodyParser = Middleware.bodyParser()
        XCTAssert(true, "Crash")
    
        let result = bodyParser(request: request, response: Response())
        
        var body = result!.request.body
        
        if let a = body["hello"] {

            XCTAssertEqual(a, "hi", "Fuck")
            
        } else {
            
            XCTAssert(true, "Crash")
        }
    }
    
    func testRouter() {
        
        let router = Router()
        let handler: TaylorHandler = {
            
            request, response in
            
            response.sent = true
            
            return (request: request, response: response)
        }
        
        let route = Route(m: .GET, path: "/hello/:whatever/jey", handlers:[handler])
        router.addRoute(route)
        
        let request = Request()
        request.method = .GET
        request.path = "/hello/hshshshs/jey"
        
        let rHandler: TaylorHandler = router.handler()

        if let r = rHandler(request:request, response: Response()){
            
            XCTAssert(r.response.sent, "Request handled")
        }
    }
    
    func testResponseGeneration() {
        
        let response = Response()
        response.stringBody = "Hello"
        
        let s = NSString(data: response.generateResponse(), encoding: NSUTF8StringEncoding)
        
        XCTAssertEqual(s, "HTTP/1.1 200 OK\r\nContent-Length: 5\r\nContent-Type: text/plain\r\n\r\nHello", "Generates")
    }
    
    func testFileTypes() {
        
        XCTAssertEqual(FileTypes.get("html"), "text/html", "Type")
        XCTAssertEqual(FileTypes.get("json"), "application/json", "Type")
    }
}
