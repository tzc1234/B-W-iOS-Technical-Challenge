//
//  DefaultDataTransferServiceTests.swift
//  B&WTests
//
//  Created by Tsz-Lung on 06/04/2024.
//

import XCTest
import B_W

final class DefaultDataTransferServiceTests: XCTestCase {
    func test_init_doesNotNotifyService() {
        let (_, service) = makeSUT()
        
        XCTAssertEqual(service.requestCallCount, 0)
    }
    
    func test_request_deliversNetworkErrorOnServiceError() {
        let (sut, service) = makeSUT()
        let endpoint = makeEndpoint()
        
        let receivedError = dataTransferError(on: sut, with: endpoint, when: {
            let anyNetworkError = NetworkError.urlGeneration
            service.complete(with: anyNetworkError)
        })
        
        if case .networkFailure = receivedError {
            return
        }
        XCTFail("Should be a network error")
    }
    
    func test_request_deliversParsingErrorOnDecodeError() {
        let (sut, service) = makeSUT()
        let endpoint = makeEndpoint()
        
        let receivedError = dataTransferError(on: sut, with: endpoint, when: {
            service.complete(with: Data("?".utf8))
        })
        
        if case .parsing = receivedError {
            return
        }
        XCTFail("Should be a parsing error")
    }
    
    func test_request_deliversNoResponseErrorWhenReceivedNoData() {
        let (sut, service) = makeSUT()
        let endpoint = makeEndpoint()
        let noData: Data? = nil
        
        let receivedError = dataTransferError(on: sut, with: endpoint, when: {
            service.complete(with: noData)
        })
        
        if case .noResponse = receivedError {
            return
        }
        XCTFail("Should be a noResponse error")
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: DefaultDataTransferService, service: NetworkServiceSpy) {
        let service = NetworkServiceSpy()
        let sut = DefaultDataTransferService(with: service)
        trackForMemoryLeaks(service, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, service)
    }
    
    private func dataTransferError(on sut: DefaultDataTransferService,
                                   with endpoint: Endpoint<Int>,
                                   when action: () -> Void,
                                   file: StaticString = #filePath,
                                   line: UInt = #line) -> DataTransferError? {
        let exp = expectation(description: "Wait for completion")
        var receivedError: DataTransferError?
        _ = sut.request(with: endpoint) { result in
            switch result {
            case .success:
                XCTFail("Should not be success", file: file, line: line)
            case let .failure(error):
                receivedError = error
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1)
        
        return receivedError
    }
    
    private func makeEndpoint(baseURL: URL = anyURL()) -> Endpoint<Int> {
        let config = ApiRequestConfig(baseURL: anyURL())
        return Endpoint<Int>(config: config, path: "", method: .get)
    }
}
