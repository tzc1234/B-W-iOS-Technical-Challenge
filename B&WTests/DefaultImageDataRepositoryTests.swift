//
//  DefaultImageDataRepositoryTests.swift
//  B&WTests
//
//  Created by Tsz-Lung on 04/04/2024.
//  Copyright © 2024 Artemis Simple Solutions Ltd. All rights reserved.
//

import XCTest
@testable import B_W

protocol ImageDataEndpoints {
    
}

struct ImageDataRepositoryEndpoints: ImageDataEndpoints {
    
}

class DefaultImageDataRepository {
    private let endpoints: ImageDataEndpoints
    private let dataTransferService: DataTransferService
    
    init(endpoints: ImageDataEndpoints, dataTransferService: DataTransferService) {
        self.endpoints = endpoints
        self.dataTransferService = dataTransferService
    }
}

final class DefaultImageDataRepositoryTests: XCTestCase {
    func test_init_doesNotNotifyDataTransferService() {
        let (_, service) = makeSUT()
        
        XCTAssertEqual(service.requestCallCount, 0)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: DefaultImageDataRepository, service: DataTransferServiceSpy) {
        let endpoints = ImageDataRepositoryEndpoints()
        let service = DataTransferServiceSpy()
        let sut = DefaultImageDataRepository(endpoints: endpoints, dataTransferService: service)
        
        trackForMemoryLeaks(service, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, service)
    }
    
    private class DataTransferServiceSpy: DataTransferService {
        private(set) var requestCallCount = 0
        
        struct Cancellable: NetworkCancellable {
            func cancel() {}
        }
        
        func request<T: Decodable, E: ResponseRequestable>(with endpoint: E,
                                                           completion: @escaping CompletionHandler<T>) -> NetworkCancellable? where E.Response == T {
            requestCallCount += 1
            return Cancellable()
        }
    }
}
