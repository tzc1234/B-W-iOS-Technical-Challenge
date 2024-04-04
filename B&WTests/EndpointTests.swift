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
        let receivedURL = try XCTUnwrap(request.url?.absoluteString)
        
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(receivedURL, "https://base-url.com/path")
    }
    
    func test_urlRequest_deliversCorrectRequestWhenBaseURLWithoutLastSlash() throws {
        let baseURLWithoutLastSlash = URL(string: "https://base-url.com")!
        let path = "path"
        let sut = makeSUT(baseURL: baseURLWithoutLastSlash, path: path)
        
        let request = try sut.urlRequest()
        let receivedURL = try XCTUnwrap(request.url?.absoluteString)
        
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(receivedURL, "https://base-url.com/path")
    }

    // MARK: - Helpers
    
    private func makeSUT(baseURL: URL, path: String, method: HTTPMethodType = .get) -> Endpoint<Any> {
        let config = ConfigStub(baseURL: baseURL)
        return Endpoint(config: config, path: path, method: method)
    }
    
    private struct ConfigStub: RequestConfig {
        let baseURL: URL
    }
}
