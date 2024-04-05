//
//  LoadImageDataUseCase.swift
//  B&W
//
//  Created by Tsz-Lung on 04/04/2024.
//

import Foundation

protocol LoadImageDataUseCase {
    typealias Result = Swift.Result<Data, Error>
    typealias Completion = (Result) -> Void
    
    func load(for url: URL, completion: @escaping Completion) -> Cancellable
}

final class DefaultLoadImageDataUseCase: LoadImageDataUseCase {
    // I doubt using DataTransferService if I only need a raw data, don't need an extra conversion/error handling.
    // Using NetworkService is much more straightforward. I would like to listen different opinions of this.:)
    private let service: NetworkService
    private let makeRequestable: (URL) -> Requestable
    
    init(service: NetworkService, makeRequestable: @escaping (URL) -> Requestable) {
        self.service = service
        self.makeRequestable = makeRequestable
    }
    
    enum Error: Swift.Error {
        case failed
        case noData
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
        
        func complete(with result: LoadImageDataUseCase.Result) {
            completion?(result)
        }
    }
    
    func load(for url: URL, completion: @escaping Completion) -> Cancellable {
        let endPoint = makeRequestable(url)
        let wrapped = Wrapper(completion)
        
        wrapped.cancellable = service.request(endpoint: endPoint) { result in
            switch result {
            case let .success(data):
                guard let data else {
                    wrapped.complete(with: .failure(Error.noData))
                    return
                }
                
                wrapped.complete(with: .success(data))
            case .failure:
                wrapped.complete(with: .failure(Error.failed))
            }
        }
        return wrapped
    }
}
