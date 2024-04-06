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
        let config = ApiRequestConfig(baseURL: anyURL())
        let endpoint = Endpoint<String>(config: config, path: "", method: .get)
        let anyNetworkError = NetworkError.urlGeneration
        
        let exp = expectation(description: "Wait for completion")
        _ = sut.request(with: endpoint) { result in
            switch result {
            case .success:
                XCTFail("Should not be here")
                
            case let .failure(error):
                guard case .networkFailure = error else {
                    XCTFail("Should be a network error")
                    return
                }
            }
            exp.fulfill()
        }
        service.complete(with: anyNetworkError)
        wait(for: [exp], timeout: 1)
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
}
