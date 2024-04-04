//
//  DefaultImageDataLoader.swift
//  B&W
//
//  Created by Tsz-Lung on 04/04/2024.
//

import Foundation

struct URLEndpoint: Requestable {
    private let url: URL
    
    init(url: URL) {
        self.url = url
    }
    
    func urlRequest() throws -> URLRequest {
        URLRequest(url: url)
    }
}

// This component shouldn't belong to Repositories, since it use NetworkService directly.
final class DefaultImageDataLoader: ImageDataLoader {
    private let service: NetworkService
    
    init(service: NetworkService) {
        self.service = service
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
        
        func complete(with result: ImageDataLoader.Result) {
            completion?(result)
        }
    }
    
    func load(for url: URL, completion: @escaping Completion) -> Cancellable {
        let endPoint = URLEndpoint(url: url)
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
