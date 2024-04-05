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
