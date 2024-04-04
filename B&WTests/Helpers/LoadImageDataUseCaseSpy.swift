//
//  LoadImageDataUseCaseSpy.swift
//  B&WTests
//
//  Created by Tsz-Lung on 04/04/2024.
//

import Foundation
@testable import B_W

final class LoadImageDataUseCaseSpy: LoadImageDataUseCase {
    struct LoadEvent {
        let url: URL
        let completion: Completion
    }
    
    private var loads = [LoadEvent]()
    var loadCallCount: Int {
        loads.count
    }
    var urls: [URL] {
        loads.map(\.url)
    }
    
    private struct LoadImageCancellable: Cancellable {
        let afterCancel: () -> Void
        
        func cancel() {
            afterCancel()
        }
    }
    
    private(set) var cancelCallCount = 0
    
    func load(for url: URL, completion: @escaping Completion) -> Cancellable {
        loads.append(LoadEvent(url: url, completion: completion))
        return LoadImageCancellable { [weak self] in
            self?.cancelCallCount += 1
        }
    }
    
    func complete(with error: Error, at index: Int = 0) {
        loads[index].completion(.failure(error))
    }
    
    func complete(with data: Data, at index: Int = 0) {
        loads[index].completion(.success(data))
    }
}
