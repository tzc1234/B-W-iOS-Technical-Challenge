//
//  ProductsRepositoryEndpointsTests.swift
//  B&WTests
//
//  Created by Tsz-Lung on 04/04/2024.
//  Copyright © 2024 Artemis Simple Solutions Ltd. All rights reserved.
//

import XCTest
@testable import B_W

final class ProductsRepositoryEndpointsTests: XCTestCase {
    func test_getProducts_deliversCorrectProductsEndpoint() {
        let baseURL = URL(string: "https://base-url.com")!
        let sut = makeSUT(baseURL: baseURL)
        
        let request = try? sut.getProducts().urlRequest()
        let requestURL = request?.url?.absoluteString
        
        XCTAssertEqual(request?.httpMethod, "GET")
        XCTAssertEqual(requestURL, "https://base-url.com/db")
    }
    
    // MARK: - Helpers
    
    private func makeSUT(baseURL: URL) -> ProductsEndpoints {
        let config = ConfigStub(baseURL: baseURL)
        return ProductsRepositoryEndpoints(config: config)
    }
}
