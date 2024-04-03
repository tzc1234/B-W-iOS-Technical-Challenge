import Foundation

public enum DataTransferError: Error {
    case noResponse
    case parsing(Error)
    case networkFailure(NetworkError)
    case resolvedNetworkFailure(Error)
}

public protocol DataTransferService {
    typealias CompletionHandler<T> = (Result<T, DataTransferError>) -> Void
    
    func request<T: Decodable, E: ResponseRequestable>(with endpoint: E,
                                                       completion: @escaping CompletionHandler<T>) -> NetworkCancellable? where E.Response == T
}

public final class DefaultDataTransferService {
    private let networkService: NetworkService
    private let errorHandler: DataTransferErrorHandler

    public init(with networkService: NetworkService,
                errorHandler: DataTransferErrorHandler = DefaultDataTransferErrorHandler()) {
        self.networkService = networkService
        self.errorHandler = errorHandler
    }
}

extension DefaultDataTransferService: DataTransferService {
    public func request<T: Decodable, E: ResponseRequestable>(with endpoint: E,
                                                              completion: @escaping CompletionHandler<T>) -> NetworkCancellable? where E.Response == T {
        return self.networkService.request(endpoint: endpoint) { result in
            switch result {
            case .success(let data):
                let result: Result<T, DataTransferError> = self.decode(data: data, decoder: endpoint.responseDecoder)
                DispatchQueue.main.async { return completion(result) }
            case .failure(let error):
                let error = self.resolve(networkError: error)
                DispatchQueue.main.async { return completion(.failure(error)) }
            }
        }
    }
    
    private func decode<T: Decodable>(data: Data?, decoder: ResponseDecoder) -> Result<T, DataTransferError> {
        do {
            guard let data = data else { return .failure(.noResponse) }
            let result: T = try decoder.decode(data)
            return .success(result)
        } catch {
            return .failure(.parsing(error))
        }
    }

    private func resolve(networkError error: NetworkError) -> DataTransferError {
        let resolvedError = self.errorHandler.handle(error: error)
        return resolvedError is NetworkError ? .networkFailure(error) : .resolvedNetworkFailure(resolvedError)
    }
}
