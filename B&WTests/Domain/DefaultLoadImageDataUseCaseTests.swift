//
//  DefaultLoadImageDataUseCaseTests.swift
//  B&WTests
//
//  Created by Tsz-Lung on 04/04/2024.
//

import XCTest
@testable import B_W

final class DefaultLoadImageDataUseCaseTests: XCTestCase {
    func test_init_doesNotNotifyService() {
        let (_, service) = makeSUT()
        
        XCTAssertEqual(service.requestCallCount, 0)
    }
    
    func test_load_passesCorrectParamsToService() throws {
        let (sut, service) = makeSUT()
        let expectedURL = URL(string: "https://image-data.com")!
        
        _ = sut.load(for: expectedURL) { _ in }
        
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
    
    func test_load_deliversDataWhenReceivedData() {
        let (sut, service) = makeSUT()
        let expectedData = Data("data".utf8)
        
        expect(sut, completeWith: .success(expectedData), when: {
            service.complete(with: expectedData)
        })
    }
    
    func test_load_cancelsRequestSuccessfully() {
        let (sut, service) = makeSUT()
        let anyData = Data("data".utf8)
        
        let task = sut.load(for: anyURL()) { _ in }
        
        XCTAssertEqual(service.cancelCallCount, 0)
        
        task.cancel()
        service.complete(with: anyData)
        
        XCTAssertEqual(service.cancelCallCount, 1)
    }
    
    func test_load_doesNotDeliverResultAfterRequestCancelled() {
        let (sut, service) = makeSUT()
        let anyData = Data("data".utf8)
        
        var completionCallCount = 0
        let task = sut.load(for: anyURL()) { _ in completionCallCount += 1 }
        task.cancel()
        service.complete(with: anyData)
        service.complete(with: nil)
        service.complete(with: .notConnected)
        
        XCTAssertEqual(completionCallCount, 0)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: LoadImageDataUseCase, service: NetworkServiceSpy) {
        let service = NetworkServiceSpy()
        let sut = DefaultLoadImageDataUseCase(service: service)
        trackForMemoryLeaks(service, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, service)
    }
    
    private func expect(_ sut: LoadImageDataUseCase,
                        completeWith expectedResult: Result<Data, DefaultLoadImageDataUseCase.Error>,
                        when action: () -> Void,
                        file: StaticString = #filePath,
                        line: UInt = #line) {
        let exp = expectation(description: "Wait for completion")
        _ = sut.load(for: anyURL()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
                
            case let (.failure(receivedError), .failure(expectedError)):
                XCTAssertEqual(receivedError as? DefaultLoadImageDataUseCase.Error, expectedError, file: file, line: line)
                
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
