//
//  URLSessionHTTPClientTests.swift
//  B&WTests
//
//  Created by Tsz-Lung on 28/04/2024.
//  Copyright © 2024 Artemis Simple Solutions Ltd. All rights reserved.
//

import XCTest

final class URLSessionHTTPClient {
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func request(_ request: URLRequest) {
        let task = session.dataTask(with: request) { data, response, error in
            
        }
        task.resume()
    }
}

final class URLSessionHTTPClientTests: XCTestCase {
    func test_request_performsRequest() {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        let sut = URLSessionHTTPClient(session: session)
        let url = URL(string: "https://rquest-url.com")!
        let expectedRequest = URLRequest(url: url)
        
        let exp = expectation(description: "Wait for observer")
        URLProtocolStub.observer = { request in
            XCTAssertEqual(request, expectedRequest)
            exp.fulfill()
        }
        sut.request(expectedRequest)
        wait(for: [exp], timeout: 1)
    }
    
    private final class URLProtocolStub: URLProtocol {
        static var observer: ((URLRequest) -> Void)?
        
        override class func canInit(with request: URLRequest) -> Bool {
            true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            request
        }
        
        override func startLoading() {
            client?.urlProtocolDidFinishLoading(self)
            
            Self.observer?(request)
        }
        
        override func stopLoading() {}
    }
}
