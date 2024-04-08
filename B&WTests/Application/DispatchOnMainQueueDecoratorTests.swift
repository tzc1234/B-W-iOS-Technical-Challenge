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
        var performOnMainQueueCount = 0
        let (_, decoratee) = makeSUT(performOnMainQueue: { action in
            action()
            performOnMainQueueCount += 1
        })
        
        XCTAssertEqual(performOnMainQueueCount, 0)
        XCTAssertEqual(decoratee.callCount, 0)
    }
    
    func test_performOnMainQueue_dispatchesDecorateeActionOnMainQueue() {
        var performOnMainQueueCount = 0
        let (sut, decoratee) = makeSUT(performOnMainQueue: { action in
            action()
            performOnMainQueueCount += 1
        })
        
        sut.run()
        
        XCTAssertEqual(performOnMainQueueCount, 1)
        XCTAssertEqual(decoratee.callCount, 1)
    }

    // MARK: - Helpers
    
    private func makeSUT(performOnMainQueue: @escaping PerformOnMainQueue = { $0() },
                         file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: DispatchOnMainQueueDecorator<DecorateeSpy>, decoratee: DecorateeSpy) {
        let decoratee = DecorateeSpy()
        let sut = DispatchOnMainQueueDecorator<DecorateeSpy>(
            decoratee: decoratee,
            performOnMainQueue: performOnMainQueue
        )
        trackForMemoryLeaks(decoratee, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, decoratee)
    }
}

final class DecorateeSpy {
    private(set) var callCount = 0
    
    func run() {
        callCount += 1
    }
}

extension DispatchOnMainQueueDecorator where T == DecorateeSpy {
    func run() {
        performOnMainQueue { [weak self] in
            self?.decoratee.run()
        }
    }
}
