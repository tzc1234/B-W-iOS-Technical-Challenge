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
