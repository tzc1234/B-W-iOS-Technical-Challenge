//
//  DefaultImageDataRepositoryTests.swift
//  B&WTests
//
//  Created by Tsz-Lung on 05/04/2024.
//  Copyright © 2024 Artemis Simple Solutions Ltd. All rights reserved.
//

import XCTest
@testable import B_W

final class DefaultImageDataRepository {
    typealias Result = Swift.Result<Data?, Error>
    typealias Completion = (Result) -> Void
    
    private let service: NetworkService
    private let makeRequestable: (URL) -> Requestable
    
    init(service: NetworkService, makeRequestable: @escaping (URL) -> Requestable) {
        self.service = service
        self.makeRequestable = makeRequestable
    }
    
    private final class Wrapper: Cancellable {
        private var completion: Completion?
        var cancellable: NetworkCancellable?
        
        init(_ completion: Completion?) {
            self.completion = completion
        }
        
        func cancel() {
            cancellable?.cancel()
            completion = nil
        }
        
        func complete(with result: Result) {
            completion?(result)
        }
    }
    
    func fetchImageData(for url: URL, completion: @escaping Completion) -> Cancellable {
        let endPoint = makeRequestable(url)
        let wrapped = Wrapper(completion)
        
        wrapped.cancellable = service.request(endpoint: endPoint) { result in
            switch result {
            case let .success(data):
                wrapped.complete(with: .success(data))
            case let .failure(error):
                wrapped.complete(with: .failure(error))
            }
        }
        return wrapped
    }
}

final class DefaultImageDataRepositoryTests: XCTestCase {
    func test_init_doesNotNotifyService() {
        let (_, service) = makeSUT()
        
        XCTAssertEqual(service.requestCallCount, 0)
    }
    
    func test_fetchImageData_passesCorrectParamsToService() throws {
        let (sut, service) = makeSUT()
        let expectedURL = URL(string: "https://image-data.com")!
        
        _ = sut.fetchImageData(for: expectedURL) { _ in }
        
        let request = try service.endpoints.first?.urlRequest()
        XCTAssertEqual(request?.url, expectedURL)
        XCTAssertEqual(request?.httpMethod, "GET")
    }
    
    func test_fetchImageData_deliversErrorOnServiceError() {
        let (sut, service) = makeSUT()
        let anyError = anyNSError()
        
        expect(sut, completeWith: .failure(anyError), when: {
            service.complete(with: .notConnected)
        })
    }
    
    func test_fetchImageData_deliversDataWhenReceivedData() {
        let (sut, service) = makeSUT()
        let expectedData = Data("data".utf8)
        
        expect(sut, completeWith: .success(expectedData), when: {
            service.complete(with: expectedData)
        })
    }
    
    func test_fetchImageData_cancelsRequestSuccessfully() {
        let (sut, service) = makeSUT()
        let anyData = Data("data".utf8)
        
        let task = sut.fetchImageData(for: anyURL()) { _ in }
        
        XCTAssertEqual(service.cancelCallCount, 0)
        
        task.cancel()
        service.complete(with: anyData)
        
        XCTAssertEqual(service.cancelCallCount, 1)
    }
    
    func test_fetchImageData_doesNotDeliverResultAfterRequestCancelled() {
        let (sut, service) = makeSUT()
        let anyData = Data("data".utf8)
        
        var completionCallCount = 0
        let task = sut.fetchImageData(for: anyURL()) { _ in completionCallCount += 1 }
        task.cancel()
        service.complete(with: anyData)
        service.complete(with: nil)
        service.complete(with: .notConnected)
        
        XCTAssertEqual(completionCallCount, 0)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: DefaultImageDataRepository, service: NetworkServiceSpy) {
        let service = NetworkServiceSpy()
        let sut = DefaultImageDataRepository(service: service, makeRequestable: URLEndpoint.init)
        trackForMemoryLeaks(service, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, service)
    }
    
    private func expect(_ sut: DefaultImageDataRepository,
                        completeWith expectedResult: Result<Data, Error>,
                        when action: () -> Void,
                        file: StaticString = #filePath,
                        line: UInt = #line) {
        let exp = expectation(description: "Wait for completion")
        _ = sut.fetchImageData(for: anyURL()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
                
            case (.failure, .failure):
                break
                
            default:
                XCTFail("Expect a result: \(expectedResult), got \(receivedResult) instead", file: file, line: line)
                
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1)
    }
    
    private final class NetworkServiceSpy: NetworkService {
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
        
        struct Cancellable: NetworkCancellable {
            let afterCancel: () -> Void
            
            func cancel() {
                afterCancel()
            }
        }
        
        private(set) var cancelCallCount = 0
        
        func request(endpoint: Requestable, completion: @escaping CompletionHandler) -> NetworkCancellable? {
            requests.append(Request(endpoint: endpoint, completion: completion))
            return Cancellable(afterCancel: { [weak self] in
                self?.cancelCallCount += 1
            })
        }
        
        func complete(with error: NetworkError, at index: Int = 0) {
            requests[index].completion(.failure(error))
        }
        
        func complete(with data: Data?, at index: Int = 0) {
            requests[index].completion(.success(data))
        }
    }
}
