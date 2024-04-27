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
        let (_, decoratee) = makeSUT()
        
        XCTAssertEqual(decoratee.requestCallCount, 0)
    }
    
    func test_performOnMainQueue_dispatchesDecorateeResultOnMainQueue() {
        let (sut, decoratee) = makeSUT()
        let expectedData = Data("expected data".utf8)
        
        let exp = expectation(description: "Wait for completion")
        _ = sut.request(endpoint: FullPathEndpoint(url: anyURL())) { result in
            XCTAssertTrue(Thread.isMainThread)
            
            switch result {
            case let .success(data):
                XCTAssertEqual(data, expectedData)
            case .failure:
                XCTFail("Should not be failure")
            }
            exp.fulfill()
        }
        
        DispatchQueue.global().async {
            decoratee.complete(with: expectedData)
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_cancelTask_cancelsRequestForwardToDecorateeCancellable() {
        let (sut, decoratee) = makeSUT()
        
        let task = sut.request(endpoint: FullPathEndpoint(url: anyURL())) { _ in }
        
        XCTAssertEqual(decoratee.cancelCallCount, 0)
        
        task.cancel()
        
        XCTAssertEqual(decoratee.cancelCallCount, 1)
    }

    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: NetworkService, decoratee: NetworkServiceSpy) {
        let decoratee = NetworkServiceSpy()
        let sut = DispatchOnMainQueueDecorator<NetworkService>(decoratee: decoratee)
        trackForMemoryLeaks(decoratee, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, decoratee)
    }
}
