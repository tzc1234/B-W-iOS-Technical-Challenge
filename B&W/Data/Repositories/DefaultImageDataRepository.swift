//
//  DefaultImageDataRepository.swift
//  B&W
//
//  Created by Tsz-Lung on 05/04/2024.
//

import Foundation

// The implementation of ImageDataRepository is somewhat a supportive collaborator,
// meeting the needs of the LoadImageDataUseCase's implementation.
// It will know the low-level component protocol (NetworkService) or closure (makeRequestable),
// communicate through the protocol/closure to those low-level concrete components (DefaultNetworkService and FullPathEndpoint).
final class DefaultImageDataRepository: ImageDataRepository {
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
        
        func complete(with result: ImageDataRepository.Result) {
            completion?(result)
        }
    }
    
    func fetchImageData(for imagePath: URL, completion: @escaping Completion) -> Cancellable {
        let endPoint = makeRequestable(imagePath)
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
