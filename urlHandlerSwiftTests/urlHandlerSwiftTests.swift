//
//  urlHandlerSwiftTests.swift
//  urlHandlerSwiftTests
//
//  Created by Rahul Malik on 02/11/14.
//  Copyright (c) 2014 Rahul Malik. All rights reserved.
//

import UIKit
import XCTest

@testable import urlHandlerSwift

class urlHandlerSwiftTests: XCTestCase {
    let baseURL = "https://httpbin.org/"
    let timeOut = 3.0;
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testBasicRequest() {
        let expectation = expectationWithDescription("UrlHandler get request")
        var expectedResponce = false
        UrlHandler.sharedInstance.basicURL("\(baseURL)get", handler: { (error, returnObject) -> Void in
            if (error == nil && returnObject != "") {
                expectedResponce = true
            }else {
                expectedResponce = false
            }
            expectation.fulfill()
        })
        waitForExpectationsWithTimeout(timeOut, handler: nil)
        XCTAssert(expectedResponce, "UrlHandler get request")
    }
    
    func testBasicError(){
        let expectation = expectationWithDescription("UrlHandler get request 404 error")
        var expectedResponce = false
        UrlHandler.sharedInstance.basicURL("\(baseURL)status/404", handler: { (error, returnObject) -> Void in
            if (error == nil && returnObject != "") {
                expectedResponce = true
            }else {
                expectedResponce = false
            }
            expectation.fulfill()
        })
        waitForExpectationsWithTimeout(timeOut, handler: nil)
        XCTAssertFalse(expectedResponce, "UrlHandler get request")
    }
    
    func testBasicDownload(){
        let expectation = expectationWithDescription("UrlHandler testBasicDownload")
        var expectedResponce = false
        UrlHandler.sharedInstance.downloadFileWithURL("\(baseURL)drip?duration=0&numbytes=5&code=200", progress: { (pre) -> Void in
            //print("progress : \(pre)")
            }) { (error, returnObject) -> Void in
                print("testBasicDownload : \(returnObject)")
                expectation.fulfill()
                expectedResponce = true
        }
         waitForExpectationsWithTimeout(timeOut, handler: nil)
        XCTAssert(expectedResponce, "UrlHandler get request")
    }
    
    func testFalseDownload(){
        let expectation = expectationWithDescription("UrlHandler testFalseDownload")
        var expectedResponce = false
        UrlHandler.sharedInstance.downloadFileWithURL("\(baseURL)drip?duration=0&numbytes=5&code=404", progress: { (pre) -> Void in
            //print("progress : \(pre)")
            }) { (error, returnObject) -> Void in
                print("testFalseDownload : \(returnObject)")
                expectation.fulfill()
                expectedResponce = true
        }
         waitForExpectationsWithTimeout(timeOut, handler: nil)
        XCTAssert(expectedResponce, "UrlHandler get request")
    }
    
    func testMultiDownload(){
        let expectation = expectationWithDescription("UrlHandler get request")
        var expectedResponce = false
        let array:NSArray = ["\(baseURL)drip?duration=0&numbytes=5&code=200",
            "\(baseURL)image/png",
            "\(baseURL)image/jpeg",
        ]
        let length = array.count
        UrlHandler.sharedInstance.downloadListOfListWithArray(array, progress: { (pre, current) -> Void in
            
            print("progress : \(pre) : \(current)")
            
            }) { (error, returnObject, current) -> Void in
                expectedResponce = true
                if length-current == 1{
                    expectation.fulfill()
                }
                print("Completed with : \(returnObject) : \(current)")
        }

         waitForExpectationsWithTimeout(timeOut, handler: nil)
        XCTAssert(expectedResponce, "UrlHandler get request")
    }
}
