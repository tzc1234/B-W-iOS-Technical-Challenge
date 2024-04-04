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
    
    enum Error: Swift.Error {
        case failed
        case noData
    }
    
    func load(for url: URL, completion: @escaping (Result<Data, Swift.Error>) -> Void) {
        let endPoint = URLEndpoint(url: url)
        _ = service.request(endpoint: endPoint) { result in
            switch result {
            case let .success(data):
                guard let data else {
                    completion(.failure(Error.noData))
                    return
                }
                
            case .failure:
                completion(.failure(Error.failed))
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
        
        sut.load(for: expectedURL) { _ in }
        
        let request = try service.endpoints.first?.urlRequest()
        XCTAssertEqual(request?.url, expectedURL)
        XCTAssertEqual(request?.httpMethod, "GET")
    }
    
    func test_load_deliversFailedErrorOnServiceError() {
        let (sut, service) = makeSUT()
        
        expect(sut, completeWith: .failure(.failed), when: {
            service.complete(with: .notConnected)
        })
    }
    
    func test_load_deliversNoDataErrorWhenReceivedNilData() {
        let (sut, service) = makeSUT()
        
        expect(sut, completeWith: .failure(.noData), when: {
            service.complete(with: nil)
        })
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
    
    private func expect(_ sut: DefaultImageDataLoader,
                        completeWith expectedResult: Result<Data, DefaultImageDataLoader.Error>,
                        when action: () -> Void,
                        file: StaticString = #filePath,
                        line: UInt = #line) {
        let exp = expectation(description: "Wait for completion")
        sut.load(for: anyURL()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case (.success, .success):
                break
            case let (.failure(receivedError), .failure(expectedError)):
                XCTAssertEqual(receivedError as? DefaultImageDataLoader.Error, expectedError, file: file, line: line)
            default:
                XCTFail("Expect a result: \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1)
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
        
        func complete(with data: Data?, at index: Int = 0) {
            requests[index].completion(.success(data))
        }
    }
}
