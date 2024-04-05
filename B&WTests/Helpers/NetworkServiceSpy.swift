//
//  NetworkServiceSpy.swift
//  B&WTests
//
//  Created by Tsz-Lung on 05/04/2024.
//

import Foundation
@testable import B_W

final class NetworkServiceSpy: NetworkService {
    struct Request {
        let endpoint: Requestable
        let completion: CompletionHandler
    }
    
    private var requests = [Request]()
    var requestCallCount: Int {
        requests.count
    }
    var endpoints: [Requestable] {
        requests.map(\.endpoint)
    }
    
    struct Cancellable: NetworkCancellable {
        let afterCancel: () -> Void
        
        func cancel() {
            afterCancel()
        }
    }
    
    private(set) var cancelCallCount = 0
    
    func request(endpoint: Requestable, completion: @escaping CompletionHandler) -> NetworkCancellable? {
        requests.append(Request(endpoint: endpoint, completion: completion))
        return Cancellable(afterCancel: { [weak self] in
            self?.cancelCallCount += 1
        })
    }
    
    func complete(with error: NetworkError, at index: Int = 0) {
        requests[index].completion(.failure(error))
    }
    
    func complete(with data: Data?, at index: Int = 0) {
        requests[index].completion(.success(data))
    }
}
