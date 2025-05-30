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
    
    func test_request_deliversResolvedNetworkFailureErrorWhenErrorHandlerUnresolvedAnError() {
        let alwaysReturnNSErrorHandler = AlwaysReturnNSErrorHandler()
        let (sut, service) = makeSUT(errorHandler: alwaysReturnNSErrorHandler)
        let endpoint = makeEndpoint()
        
        let receivedError = dataTransferError(on: sut, with: endpoint, when: {
            let anyNetworkError = NetworkError.urlGeneration
            service.complete(with: anyNetworkError)
        })
        
        if case .resolvedNetworkFailure = receivedError {
            return
        }
        XCTFail("Should be a resolvedNetworkFailure error")
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
    
    func test_request_deliversDecodedValueProperly() {
        let (sut, service) = makeSUT()
        let endpoint = makeEndpoint()
        let expectedValue = 123
        
        let decodedValue = decodedValue(on: sut, with: endpoint, when: {
            service.complete(with: Data("\(expectedValue)".utf8))
        })
        
        XCTAssertEqual(decodedValue, expectedValue)
    }
    
    func test_cancelTask_cancelsANetworkTaskProperly() {
        let (sut, service) = makeSUT()
        let endpoint = makeEndpoint()
        
        let task = sut.request(with: endpoint, responseType: Int.self) { _ in }
        
        XCTAssertEqual(service.cancelCallCount, 0)
        
        task?.cancel()
        
        XCTAssertEqual(service.cancelCallCount, 1)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(errorHandler: DataTransferErrorHandler = DefaultDataTransferErrorHandler(),
                         file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: DefaultDataTransferService, service: NetworkServiceSpy) {
        let service = NetworkServiceSpy()
        let sut = DefaultDataTransferService(with: service, errorHandler: errorHandler)
        trackForMemoryLeaks(service, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, service)
    }
    
    private func decodedValue(on sut: DefaultDataTransferService,
                              with endpoint: Endpoint,
                              when action: () -> Void,
                              file: StaticString = #filePath,
                              line: UInt = #line) -> Int? {
        switch result(on: sut, with: endpoint, when: action, file: file, line: line) {
        case let .success(value):
            return value
        case .failure:
            XCTFail("Should not fail", file: file, line: line)
            return nil
        }
    }
    
    private func dataTransferError(on sut: DefaultDataTransferService,
                                   with endpoint: Endpoint,
                                   when action: () -> Void,
                                   file: StaticString = #filePath,
                                   line: UInt = #line) -> DataTransferError? {
        switch result(on: sut, with: endpoint, when: action, file: file, line: line) {
        case .success:
            XCTFail("Should not be success", file: file, line: line)
            return nil
        case let .failure(error):
            return error
        }
    }
    
    private func result(on sut: DefaultDataTransferService,
                        with endpoint: Endpoint,
                        when action: () -> Void,
                        file: StaticString = #filePath,
                        line: UInt = #line) -> Result<Int, DataTransferError> {
        let exp = expectation(description: "Wait for completion")
        var receivedResult: Result<Int, DataTransferError>!
        _ = sut.request(with: endpoint, responseType: Int.self) { result in
            receivedResult = result
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1)
        
        return receivedResult
    }
    
    private func makeEndpoint(baseURL: URL = anyURL()) -> Endpoint {
        let config = ApiRequestConfig(baseURL: anyURL())
        return Endpoint(config: config, path: "", method: .get)
    }
    
    private final class AlwaysReturnNSErrorHandler: DataTransferErrorHandler {
        func handle(error: NetworkError) -> Error {
            anyNSError()
        }
    }
}
