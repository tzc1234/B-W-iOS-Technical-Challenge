//
//  ProductsRepositoryEndpointsTests.swift
//  B&WTests
//
//  Created by Tsz-Lung on 04/04/2024.
//

import XCTest
@testable import B_W

final class ProductsRepositoryEndpointsTests: XCTestCase {
    func test_getProducts_deliversCorrectProductsEndpoint() {
        let baseURL = URL(string: "https://base-url.com")!
        let sut = makeSUT(baseURL: baseURL)
        
        let request = sut.getProducts().urlRequest()
        let requestURL = request.url?.absoluteString
        
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(requestURL, "https://base-url.com/")
    }
    
    // MARK: - Helpers
    
    private func makeSUT(baseURL: URL) -> ProductsEndpoints {
        let config = ConfigStub(baseURL: baseURL)
        return ProductsRepositoryEndpoints(config: config)
    }
}
