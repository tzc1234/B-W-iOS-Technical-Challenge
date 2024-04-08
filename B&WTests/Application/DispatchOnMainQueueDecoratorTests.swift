//
//  DispatchOnMainQueueDecoratorTests.swift
//  B&WTests
//
//  Created by Tsz-Lung on 08/04/2024.
//

import XCTest
@testable import B_W

final class DispatchOnMainQueueDecorator<T> {
    private let decoratee: T
    private let performOnMainQueue: PerformOnMainQueue
    
    init(decoratee: T, 
         performOnMainQueue: @escaping PerformOnMainQueue = DispatchQueue.performOnMainQueue()) {
        self.decoratee = decoratee
        self.performOnMainQueue = performOnMainQueue
    }
}

final class DispatchOnMainQueueDecoratorTests: XCTestCase {
    func test_init_doesNotNotifyDecoratee() {
        let (_, decoratee) = makeSUT()
        
        XCTAssertEqual(decoratee.callCount, 0)
    }

    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: DispatchOnMainQueueDecorator<DecorateeSpy>, decoratee: DecorateeSpy) {
        let decoratee = DecorateeSpy()
        let sut = DispatchOnMainQueueDecorator<DecorateeSpy>(decoratee: decoratee, performOnMainQueue: { $0() })
        trackForMemoryLeaks(decoratee, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, decoratee)
    }
    
    private final class DecorateeSpy {
        private(set) var callCount = 0
        
        func run() {
            callCount += 1
        }
    }
}
