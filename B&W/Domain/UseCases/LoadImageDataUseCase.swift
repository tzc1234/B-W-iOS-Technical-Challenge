//
//  LoadImageDataUseCase.swift
//  B&W
//
//  Created by Tsz-Lung on 04/04/2024.
//

import Foundation

protocol LoadImageDataUseCase {
    typealias Completion = (Result<Data, Error>) -> Void
    
    func load(for url: URL, completion: @escaping Completion) -> Cancellable
}

// DefaultLoadImageDataUseCase will encapsulate the business logic/rules, knowing "what to do".
// The business logic of this use case
//  - happy path: load image data by an URL
//  - sad path: delivers failed/noData error

// In order to emphasise this business logic, this component will delegate "how to do" to someone.
// Asking for an image data from its collaborator through the `ImageDataRepository` protocol, the `URL` param,
// and finally get the `Data` back.
// This whole loading process embodies the business logic: load image data by an URL. Similarly the sad path.

// Also in order to emphasise this business logic, avoiding directly load image data from low-level components/abstractions.
// Let those low-level components/abstractions utilise by the collaborator (ImageDataRepository).
final class DefaultLoadImageDataUseCase: LoadImageDataUseCase {
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
