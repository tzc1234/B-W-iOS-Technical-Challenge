//
//  DefaultImageDataLoaderTests.swift
//  B&WTests
//
//  Created by Tsz-Lung on 04/04/2024.
//

import XCTest
@testable import B_W

final class DefaultImageDataLoader {
    private let service: NetworkService
    
    init(service: NetworkService) {
        self.service = service
    }
}

final class DefaultImageDataLoaderTests: XCTestCase {
    func test_init_doesNotNotifyService() {
        let (_, service) = makeSUT()
        
        XCTAssertEqual(service.requestCallCount, 0)
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
    
    private class NetworkServiceSpy: NetworkService {
        private(set) var requestCallCount = 0
        
        func request(endpoint: Requestable, completion: @escaping CompletionHandler) -> NetworkCancellable? {
            requestCallCount += 1
            return nil
        }
    }
}
