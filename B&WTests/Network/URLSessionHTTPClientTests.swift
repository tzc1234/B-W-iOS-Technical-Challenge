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
    
    func request(_ request: URLRequest, completion: @escaping (Result<(Data, HTTPURLResponse), Error>) -> Void) {
        let task = session.dataTask(with: request) { data, response, error in
            if let error {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}

final class URLSessionHTTPClientTests: XCTestCase {
    func test_request_performsRequest() {
        let sut = makeSUT()
        let url = URL(string: "https://request-url.com")!
        var expectedRequest = URLRequest(url: url)
        expectedRequest.httpMethod = "GET"
        
        let exp = expectation(description: "Wait for observer")
        URLProtocolStub.observer = { request in
            XCTAssertEqual(request, expectedRequest)
            exp.fulfill()
        }
        sut.request(expectedRequest) { _ in }
        wait(for: [exp], timeout: 1)
    }
    
    func test_request_failsOnRequestError() {
        let sut = makeSUT()
        URLProtocolStub.stub(data: nil, response: nil, error: anyNSError())
        
        let exp = expectation(description: "Wait for completion")
        sut.request(URLRequest(url: anyURL())) { result in
            switch result {
            case .failure:
                break
            default:
                XCTFail("Should be a failure")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> URLSessionHTTPClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        let sut = URLSessionHTTPClient(session: session)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private final class URLProtocolStub: URLProtocol {
        private struct Stub {
            let data: Data?
            let response: HTTPURLResponse?
            let error: Error?
        }
        
        static var observer: ((URLRequest) -> Void)?
        
        private static let queue = DispatchQueue(label: "URLProtocolStub.queue")
        private static var _stub: Stub?
        private static var stub: Stub? {
            get { queue.sync { _stub } }
            set { queue.sync { _stub = newValue } }
        }
        
        static func stub(data: Data?, response: HTTPURLResponse?, error: Error?) {
            stub = Stub(data: data, response: response, error: error)
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            request
        }
        
        override func startLoading() {
            let stub = Self.stub
            
            if let data = stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            } else {
                client?.urlProtocolDidFinishLoading(self)
            }
            
            Self.observer?(request)
        }
        
        override func stopLoading() {}
    }
}
