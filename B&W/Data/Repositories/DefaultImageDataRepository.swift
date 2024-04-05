//
//  DefaultImageDataRepository.swift
//  B&W
//
//  Created by Tsz-Lung on 05/04/2024.
//

import Foundation

final class DefaultImageDataRepository {
    typealias Result = Swift.Result<Data?, Error>
    typealias Completion = (Result) -> Void
    
    private let service: NetworkService
    private let makeRequestable: (URL) -> Requestable
    
    init(service: NetworkService, makeRequestable: @escaping (URL) -> Requestable) {
        self.service = service
        self.makeRequestable = makeRequestable
    }
    
    private final class Wrapper: Cancellable {
        private var completion: Completion?
        var cancellable: NetworkCancellable?
        
        init(_ completion: Completion?) {
            self.completion = completion
        }
        
        func cancel() {
            cancellable?.cancel()
            completion = nil
        }
        
        func complete(with result: Result) {
            completion?(result)
        }
    }
    
    func fetchImageData(for url: URL, completion: @escaping Completion) -> Cancellable {
        let endPoint = makeRequestable(url)
        let wrapped = Wrapper(completion)
        
        wrapped.cancellable = service.request(endpoint: endPoint) { result in
            switch result {
            case let .success(data):
                wrapped.complete(with: .success(data))
            case let .failure(error):
                wrapped.complete(with: .failure(error))
            }
        }
        return wrapped
    }
}
