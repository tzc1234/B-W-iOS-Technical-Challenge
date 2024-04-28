//
//  URLSessionHTTPClientTests.swift
//  B&WTests
//
//  Created by Tsz-Lung on 28/04/2024.
//

import XCTest
import B_W

final class URLSessionHTTPClientTests: XCTestCase {
    override func setUp() {
        super.setUp()
        
        URLProtocolStub.reset()
    }
    
    override func tearDown() {
        super.tearDown()
        
        URLProtocolStub.reset()
    }
    
    func test_request_performsRequest() {
        let sut = makeSUT()
        let url = URL(string: "https://request-url.com")!
        var expectedRequest = URLRequest(url: url)
        expectedRequest.httpMethod = "GET"
        
        let exp = expectation(description: "Wait for observe")
        URLProtocolStub.observe { request in
            XCTAssertEqual(request, expectedRequest)
            exp.fulfill()
        }
        _ = sut.request(expectedRequest) { _ in }
        wait(for: [exp], timeout: 1)
    }
    
    func test_request_failsOnRequestError() {
        let requestError = errorFor((data: nil, response: nil, error: anyNSError()))
        
        XCTAssertNotNil(requestError)
    }
    
    func test_request_failsOnAllInvalidRepresentationErrors() {
        XCTAssertNotNil(errorFor((data: nil, response: nil, error: nil)))
        XCTAssertNotNil(errorFor((data: anyData(), response: nil, error: nil)))
        XCTAssertNotNil(errorFor((data: nil, response: nonHTTPURLResponse(), error: nil)))
        XCTAssertNotNil(errorFor((data: anyData(), response: nil, error: anyNSError())))
        XCTAssertNotNil(errorFor((data: nil, response: nonHTTPURLResponse(), error: anyNSError())))
        XCTAssertNotNil(errorFor((data: nil, response: anyHTTPURLResponse(), error: anyNSError())))
        XCTAssertNotNil(errorFor((data: anyData(), response: nonHTTPURLResponse(), error: nil)))
        XCTAssertNotNil(errorFor((data: anyData(), response: nonHTTPURLResponse(), error: anyNSError())))
        XCTAssertNotNil(errorFor((data: anyData(), response: anyHTTPURLResponse(), error: anyNSError())))
    }
    
    func test_request_succeedsOnHTTPRequestWithData() throws {
        let expectedData = anyData()
        let httpRequest = anyHTTPURLResponse()
        
        let (data, response) = try XCTUnwrap(valueFor((data: expectedData, response: httpRequest, error: nil)))
        
        XCTAssertEqual(data, expectedData)
        XCTAssertEqual(response.url, httpRequest.url)
        XCTAssertEqual(response.statusCode, httpRequest.statusCode)
    }
    
    func test_request_succeedsOnHTTPRequestWithNilData() throws {
        let httpRequest = anyHTTPURLResponse()
        
        let (data, response) = try XCTUnwrap(valueFor((data: nil, response: httpRequest, error: nil)))
        
        XCTAssertTrue(data.isEmpty)
        XCTAssertEqual(response.url, httpRequest.url)
        XCTAssertEqual(response.statusCode, httpRequest.statusCode)
    }
    
    func test_cancelTask_cancelsRequest() throws {
        let receivedError = try XCTUnwrap(errorFor(taskHandler: { $0.cancel() }) as? NSError)
        
        XCTAssertEqual(receivedError.code, URLError.cancelled.rawValue)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> HTTPClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        let sut = URLSessionHTTPClient(session: session)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func valueFor(_ value: (data: Data?, response: URLResponse?, error: Error?),
                          file: StaticString = #filePath,
                          line: UInt = #line) -> (Data, HTTPURLResponse)? {
        let result = resultFor(value, file: file, line: line)
        
        var receivedValue: (Data, HTTPURLResponse)?
        switch result {
        case let .success((data, response)):
            receivedValue = (data, response)
        default:
            XCTFail("Expect a success, got \(result) instead", file: file, line: line)
        }
        
        return receivedValue
    }
    
    private func errorFor(_ value: (data: Data?, response: URLResponse?, error: Error?)? = nil,
                          taskHandler: (HTTPClientTask) -> Void = { _ in },
                          file: StaticString = #filePath,
                          line: UInt = #line) -> Error? {
        let result = resultFor(value, taskHandler: taskHandler, file: file, line: line)
        
        var receivedError: Error?
        switch result {
        case let .failure(error):
            receivedError = error
        default:
            XCTFail("Expect a failure, got \(result) instead", file: file, line: line)
        }
        
        return receivedError
    }
    
    private func resultFor(_ value: (data: Data?, response: URLResponse?, error: Error?)? = nil,
                           taskHandler: (HTTPClientTask) -> Void = { _ in },
                           file: StaticString = #filePath,
                           line: UInt = #line) -> HTTPClient.Result {
        let sut = makeSUT(file: file, line: line)
        value.map { URLProtocolStub.stub(data: $0, response: $1, error: $2) }
        
        var receivedResult: HTTPClient.Result?
        let exp = expectation(description: "Wait for completion")
        taskHandler(sut.request(URLRequest(url: anyURL())) { result in
            receivedResult = result
            exp.fulfill()
        })
        wait(for: [exp], timeout: 1)
        
        return receivedResult!
    }
    
    private func anyData() -> Data {
        Data("any".utf8)
    }
    
    private func nonHTTPURLResponse() -> URLResponse {
        URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private func anyHTTPURLResponse() -> HTTPURLResponse {
        HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
    
    private final class URLProtocolStub: URLProtocol {
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
            let observer: ((URLRequest) -> Void)?
        }
        
        private static let queue = DispatchQueue(label: "URLProtocolStub.queue")
        private static var _stub: Stub?
        private static var stub: Stub? {
            get { queue.sync { _stub } }
            set { queue.sync { _stub = newValue } }
        }
        
        static func observe(_ observer: @escaping (URLRequest) -> Void) {
            stub = Stub(data: nil, response: nil, error: nil, observer: observer)
        }
        
        static func stub(data: Data?, response: URLResponse?, error: Error?) {
            stub = Stub(data: data, response: response, error: error, observer: nil)
        }
        
        static func reset() {
            stub = nil
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
            
            stub?.observer?(request)
        }
        
        override func stopLoading() {}
    }
}
