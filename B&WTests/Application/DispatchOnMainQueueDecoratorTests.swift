//
//  DispatchOnMainQueueDecoratorTests.swift
//  B&WTests
//
//  Created by Tsz-Lung on 08/04/2024.
//

import XCTest
@testable import B_W

final class DispatchOnMainQueueDecoratorTests: XCTestCase {
    func test_init_doesNotNotifyDecoratee() {
        var performOnMainQueueCount = 0
        let (_, decoratee) = makeSUT(performOnMainQueue: { action in
            action()
            performOnMainQueueCount += 1
        })
        
        XCTAssertEqual(performOnMainQueueCount, 0)
        XCTAssertEqual(decoratee.requestCallCount, 0)
    }
    
    func test_performOnMainQueue_dispatchesDecorateeActionOnMainQueue() {
        var performOnMainQueueCount = 0
        let (sut, decoratee) = makeSUT(performOnMainQueue: { action in
            action()
            performOnMainQueueCount += 1
        })
        
        _ = sut.request(endpoint: FullPathEndpoint(url: anyURL())) { _ in }
        decoratee.complete(with: nil)
        
        XCTAssertEqual(performOnMainQueueCount, 1)
        XCTAssertEqual(decoratee.requestCallCount, 1)
    }

    // MARK: - Helpers
    
    private func makeSUT(performOnMainQueue: @escaping PerformOnMainQueue = { $0() },
                         file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: DispatchOnMainQueueDecorator<NetworkService>, decoratee: NetworkServiceSpy) {
        let decoratee = NetworkServiceSpy()
        let sut = DispatchOnMainQueueDecorator<NetworkService>(
            decoratee: decoratee,
            performOnMainQueue: performOnMainQueue
        )
        trackForMemoryLeaks(decoratee, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, decoratee)
    }
}
