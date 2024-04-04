//
//  DefaultImageDataLoaderTests.swift
//  B&WTests
//
//  Created by Tsz-Lung on 04/04/2024.
//

import XCTest
@testable import B_W

struct URLEndpoint: Requestable {
    private let url: URL
    
    init(url: URL) {
        self.url = url
    }
    
    func urlRequest() throws -> URLRequest {
        return URLRequest(url: url)
    }
}

final class DefaultImageDataLoader {
    private let service: NetworkService
    
    init(service: NetworkService) {
        self.service = service
    }
    
    func load(for url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        let endPoint = URLEndpoint(url: url)
        _ = service.request(endpoint: endPoint) { result in
            switch result {
            case .success(_):
                break
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}

final class DefaultImageDataLoaderTests: XCTestCase {
    func test_init_doesNotNotifyService() {
        let (_, service) = makeSUT()
        
        XCTAssertEqual(service.requestCallCount, 0)
    }
    
    func test_load_passesCorrectParamsToService() throws {
        let (sut, service) = makeSUT()
        let expectedURL = URL(string: "https://image-data.com")!
        
        let exp = expectation(description: "Wait for completion")
        sut.load(for: expectedURL) { _ in exp.fulfill() }
        service.complete(with: .notConnected)
        wait(for: [exp], timeout: 1)
        
        let request = try service.endpoints.first?.urlRequest()
        XCTAssertEqual(request?.url, expectedURL)
        XCTAssertEqual(request?.httpMethod, "GET")
    }
    
    func test_load_deliversErrorWhenOnServiceError() {
        let (sut, service) = makeSUT()
        
        let exp = expectation(description: "Wait for completion")
        sut.load(for: anyURL()) { result in
            switch result {
            case .success:
                XCTFail("should not be here")
            case let .failure(error):
                break
            }
            exp.fulfill()
        }
        
        service.complete(with: .notConnected)
        wait(for: [exp], timeout: 1)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: DefaultImageDataLoader, service: NetworkServiceSpy) {
        let service = NetworkServiceSpy()
        let sut = DefaultImageDataLoader(service: service)
        trackForMemoryLeaks(service, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, service)
    }
    
    private func anyURL() -> URL {
        URL(string: "https://any-url.com")!
    }
    
    private class NetworkServiceSpy: NetworkService {
        struct Request {
            let endpoint: Requestable
            let completion: CompletionHandler
        }
        
        private var requests = [Request]()
        var requestCallCount: Int {
            requests.count
        }
        var endpoints: [Requestable] {
            requests.map(\.endpoint)
        }
        
        func request(endpoint: Requestable, completion: @escaping CompletionHandler) -> NetworkCancellable? {
            requests.append(Request(endpoint: endpoint, completion: completion))
            return nil
        }
        
        func complete(with error: NetworkError, at index: Int = 0) {
            requests[index].completion(.failure(error))
        }
    }
}
