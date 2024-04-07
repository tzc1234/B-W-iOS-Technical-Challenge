import Foundation

final class DefaultProductsRepository {
    private let endpoints: ProductsEndpoints
    private let dataTransferService: DataTransferService

    init(endpoints: ProductsEndpoints, dataTransferService: DataTransferService) {
        self.endpoints = endpoints
        self.dataTransferService = dataTransferService
    }
}

extension DefaultProductsRepository: ProductsRepository {
    public func fetchProductsList(refinement: Refinement,
                                  completion: @escaping (Result<Products, Error>) -> Void) -> Cancellable? {
        let task = RepositoryTask()

        // Why do task.isCancelled guarding here just after task initialisation? It must be false at this time.
        guard !task.isCancelled else { return nil }

        let endpoint = endpoints.getProducts()
        // I guess the refinement.query will be appended to endpoint in real scenario.
        
        task.networkTask = dataTransferService
            .request(with: endpoint, responseType: ProductResponseDTO.self) { result in
                switch result {
                case .success(let responseDTO):
                    completion(.success(responseDTO.toDomain()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        return task
    }
}
