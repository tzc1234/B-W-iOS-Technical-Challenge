//
//  FullPathEndpointTests.swift
//  B&WTests
//
//  Created by Tsz-Lung on 06/04/2024.
//  Copyright © 2024 Artemis Simple Solutions Ltd. All rights reserved.
//

import XCTest
import B_W

final class FullPathEndpointTests: XCTestCase {
    func test_urlRequest_requestsByURL() {
        let url = URL(string: "https://url.com")!
        let sut = FullPathEndpoint(url: url)
        
        let request = sut.urlRequest()
        
        XCTAssertEqual(request.url, url)
        XCTAssertEqual(request.httpMethod, "GET")
    }
}
