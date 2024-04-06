//
//  DefaultImageDataRepositoryTests.swift
//  B&WTests
//
//  Created by Tsz-Lung on 05/04/2024.
//  Copyright © 2024 Artemis Simple Solutions Ltd. All rights reserved.
//

import XCTest
@testable import B_W

final class DefaultImageDataRepositoryTests: XCTestCase {
    func test_init_doesNotNotifyService() {
        let (_, service) = makeSUT()
        
        XCTAssertEqual(service.requestCallCount, 0)
    }
    
    func test_fetchImageData_passesCorrectParamsToService() throws {
        let (sut, service) = makeSUT()
        let expectedURL = URL(string: "https://image-data.com")!
        
        _ = sut.fetchImageData(for: expectedURL) { _ in }
        
        let request = try service.endpoints.first?.urlRequest()
        XCTAssertEqual(request?.url, expectedURL)
        XCTAssertEqual(request?.httpMethod, "GET")
    }
    
    func test_fetchImageData_deliversErrorOnServiceError() {
        let (sut, service) = makeSUT()
        let anyError = anyNSError()
        
        expect(sut, completeWith: .failure(anyError), when: {
            service.complete(with: .notConnected)
        })
    }
    
    func test_fetchImageData_deliversNilDataWhenReceivedNilData() {
        let (sut, service) = makeSUT()
        let nilData: Data? = nil
        
        expect(sut, completeWith: .success(nilData), when: {
            service.complete(with: nilData)
        })
    }
    
    func test_fetchImageData_deliversImageDataWhenReceivedImageData() {
        let (sut, service) = makeSUT()
        let expectedImageData = UIImage.make(withColor: .gray).pngData()!
        
        expect(sut, completeWith: .success(expectedImageData), when: {
            service.complete(with: expectedImageData)
        })
    }
    
    func test_fetchImageData_cancelsRequestSuccessfully() {
        let (sut, service) = makeSUT()
        let anyData = Data("data".utf8)
        
        let task = sut.fetchImageData(for: anyURL()) { _ in }
        
        XCTAssertEqual(service.cancelCallCount, 0)
        
        task.cancel()
        service.complete(with: anyData)
        
        XCTAssertEqual(service.cancelCallCount, 1)
    }
    
    func test_fetchImageData_doesNotDeliverResultAfterRequestCancelled() {
        let (sut, service) = makeSUT()
        let anyData = Data("data".utf8)
        
        var completionCallCount = 0
        let task = sut.fetchImageData(for: anyURL()) { _ in completionCallCount += 1 }
        task.cancel()
        service.complete(with: anyData)
        service.complete(with: nil)
        service.complete(with: .notConnected)
        
        XCTAssertEqual(completionCallCount, 0)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: ImageDataRepository, service: NetworkServiceSpy) {
        let service = NetworkServiceSpy()
        let sut = DefaultImageDataRepository(service: service, makeRequestable: FullPathEndpoint.init)
        trackForMemoryLeaks(service, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, service)
    }
    
    private func expect(_ sut: ImageDataRepository,
                        completeWith expectedResult: Result<Data?, Error>,
                        when action: () -> Void,
                        file: StaticString = #filePath,
                        line: UInt = #line) {
        let exp = expectation(description: "Wait for completion")
        _ = sut.fetchImageData(for: anyURL()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
                
            case (.failure, .failure):
                break
                
            default:
                XCTFail("Expect a result: \(expectedResult), got \(receivedResult) instead", file: file, line: line)
                
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1)
    }
}
