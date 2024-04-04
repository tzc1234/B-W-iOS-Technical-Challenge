//
//  EndpointTests.swift
//  B&WTests
//
//  Created by Tsz-Lung on 04/04/2024.
//  Copyright © 2024 Artemis Simple Solutions Ltd. All rights reserved.
//

import XCTest
import B_W

final class EndpointTests: XCTestCase {
    func test_urlRequest_deliversCorrectRequestWhenBaseURLWithLastSlash() throws {
        let baseURLWithLastSlash = URL(string: "https://base-url.com/")!
        let path = "path"
        let sut = makeSUT(baseURL: baseURLWithLastSlash, path: path)
        
        let request = try sut.urlRequest()
        let requestURL = try XCTUnwrap(request.url?.absoluteString)
        
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(requestURL, "https://base-url.com/path")
    }
    
    func test_urlRequest_deliversCorrectRequestWhenBaseURLWithoutLastSlash() throws {
        let baseURLWithoutLastSlash = URL(string: "https://base-url.com")!
        let path = "path"
        let sut = makeSUT(baseURL: baseURLWithoutLastSlash, path: path)
        
        let request = try sut.urlRequest()
        let requestURL = try XCTUnwrap(request.url?.absoluteString)
        
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(requestURL, "https://base-url.com/path")
    }
    
    func test_urlRequest_deliversCorrectRequestWhenEmptyPath() throws {
        let baseURL = URL(string: "https://base-url.com")!
        let emptyPath = ""
        let sut = makeSUT(baseURL: baseURL, path: emptyPath)
        
        let request = try sut.urlRequest()
        let requestURL = try XCTUnwrap(request.url?.absoluteString)
        
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(requestURL, "https://base-url.com/")
    }
    
    func test_urlRequest_deliversCorrectRequestWhenIsFullPath() throws {
        let fullPath = "https://full-path.com/"
        let sut = makeSUT(path: fullPath, isFullPath: true)
        
        let request = try sut.urlRequest()
        let requestURL = try XCTUnwrap(request.url?.absoluteString)
        
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(requestURL, fullPath)
    }
    
    func test_urlRequest_throwsRequestErrorWhenInvalidFullPath() {
        let invalidFullPath = "https://full-path.com[/]"
        let sut = makeSUT(path: invalidFullPath, isFullPath: true)
        
        XCTAssertThrowsError(try sut.urlRequest()) { error in
            XCTAssertEqual(error as? RequestError, .componentsError)
        }
    }
    
    func test_urlRequest_throwsRequestErrorWhenEmptyFullPath() {
        let emptyFullPath = ""
        let sut = makeSUT(path: emptyFullPath, isFullPath: true)
        
        XCTAssertThrowsError(try sut.urlRequest()) { error in
            XCTAssertEqual(error as? RequestError, .componentsError)
        }
    }

    // MARK: - Helpers
    
    private func makeSUT(baseURL: URL = URL(string: "https://any-url.com/")!,
                         path: String,
                         isFullPath: Bool = false,
                         method: HTTPMethodType = .get) -> Endpoint<Any> {
        let config = ConfigStub(baseURL: baseURL)
        return Endpoint(config: config, path: path, isFullPath: isFullPath, method: method)
    }
}
