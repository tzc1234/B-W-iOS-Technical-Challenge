//
//  _DefaultLoadImageDataUseCaseTests.swift
//  B&WTests
//
//  Created by Tsz-Lung on 05/04/2024.
//

import XCTest
@testable import B_W

final class _DefaultLoadImageDataUseCase: LoadImageDataUseCase {
    private let repository: ImageDataRepository
    
    init(repository: ImageDataRepository) {
        self.repository = repository
    }
    
    enum Error: Swift.Error {
        case failed
        case noData
    }
    
    func load(for url: URL, completion: @escaping Completion) -> Cancellable {
        repository.fetchImageData(for: url) { result in
            switch result {
            case let .success(data):
                guard let data else {
                    completion(.failure(Error.noData))
                    return
                }
                
                completion(.success(data))
            case .failure:
                completion(.failure(Error.failed))
            }
        }
    }
}

final class _DefaultLoadImageDataUseCaseTests: XCTestCase {
    func test_init_doesNotNotifyRepository() {
        let (_, repository) = makeSUT()
        
        XCTAssertEqual(repository.fetchImageDataCallCount, 0)
    }
    
    func test_load_passesURLToRepositoryCorrectly() throws {
        let (sut, repository) = makeSUT()
        let expectedURL = URL(string: "https://image-data.com")!
        
        _ = sut.load(for: expectedURL) { _ in }
        
        XCTAssertEqual(repository.loggedURLs, [expectedURL])
    }
    
    func test_load_deliversFailedErrorOnRepositoryError() {
        let (sut, repository) = makeSUT()
        
        expect(sut, completeWith: .failure(.failed), when: {
            repository.complete(with: .notConnected)
        })
    }
    
    func test_load_deliversNoDataErrorWhenReceivedNilData() {
        let (sut, repository) = makeSUT()
        
        expect(sut, completeWith: .failure(.noData), when: {
            repository.complete(with: nil)
        })
    }
    
    func test_load_deliversImageDataWhenReceivedData() {
        let (sut, repository) = makeSUT()
        let expectedImageData = Data("image data".utf8)
        
        expect(sut, completeWith: .success(expectedImageData), when: {
            repository.complete(with: expectedImageData)
        })
    }
    
    func test_load_cancelsRequestSuccessfully() {
        let (sut, repository) = makeSUT()
        let anyData = Data("data".utf8)
        
        let task = sut.load(for: anyURL()) { _ in }
        
        XCTAssertEqual(repository.cancelCallCount, 0)
        
        task.cancel()
        repository.complete(with: anyData)
        
        XCTAssertEqual(repository.cancelCallCount, 1)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: _DefaultLoadImageDataUseCase, repository: ImageDataRepositorySpy) {
        let repository = ImageDataRepositorySpy()
        let sut = _DefaultLoadImageDataUseCase(repository: repository)
        trackForMemoryLeaks(repository, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, repository)
    }
    
    private func expect(_ sut: _DefaultLoadImageDataUseCase,
                        completeWith expectedResult: Result<Data, _DefaultLoadImageDataUseCase.Error>,
                        when action: () -> Void,
                        file: StaticString = #filePath,
                        line: UInt = #line) {
        let exp = expectation(description: "Wait for completion")
        _ = sut.load(for: anyURL()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
                
            case let (.failure(receivedError), .failure(expectedError)):
                XCTAssertEqual(receivedError as? _DefaultLoadImageDataUseCase.Error, expectedError, file: file, line: line)
                
            default:
                XCTFail("Expect a result: \(expectedResult), got \(receivedResult) instead", file: file, line: line)
                
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1)
    }
    
    private final class ImageDataRepositorySpy: ImageDataRepository {
        private struct Event {
            let url: URL
            let completion: Completion
        }
        
        private var events = [Event]()
        var fetchImageDataCallCount: Int {
            events.count
        }
        var loggedURLs: [URL] {
            events.map(\.url)
        }
        
        private struct RepositoryCancellable: Cancellable {
            let afterCancel: () -> Void
            
            func cancel() {
                afterCancel()
            }
        }
        
        private(set) var cancelCallCount = 0
        
        func fetchImageData(for url: URL, completion: @escaping Completion) -> Cancellable {
            events.append(Event(url: url, completion: completion))
            return RepositoryCancellable(afterCancel: { [weak self] in
                self?.cancelCallCount += 1
            })
        }
        
        func complete(with error: NetworkError, at index: Int = 0) {
            events[index].completion(.failure(error))
        }
        
        func complete(with data: Data?, at index: Int = 0) {
            events[index].completion(.success(data))
        }
    }
}
