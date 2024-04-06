import Foundation

public enum DataTransferError: Error {
    case noResponse
    case parsing(Error)
    case networkFailure(NetworkError)
    case resolvedNetworkFailure(Error)
}

public protocol DataTransferService {
    typealias CompletionHandler<T> = (Result<T, DataTransferError>) -> Void
    
    func request<T: Decodable>(with endpoint: Requestable,
                               responseType: T.Type,
                               completion: @escaping CompletionHandler<T>) -> NetworkCancellable?
}

public final class DefaultDataTransferService {
    private let networkService: NetworkService
    private let errorHandler: DataTransferErrorHandler
    private let responseDecoder: ResponseDecoder

    public init(with networkService: NetworkService,
                errorHandler: DataTransferErrorHandler = DefaultDataTransferErrorHandler(),
                responseDecoder: ResponseDecoder = JSONResponseDecoder()) {
        self.networkService = networkService
        self.errorHandler = errorHandler
        self.responseDecoder = responseDecoder
    }
}

extension DefaultDataTransferService: DataTransferService {
    public func request<T: Decodable>(with endpoint: Requestable,
                                      responseType: T.Type,
                                      completion: @escaping CompletionHandler<T>) -> NetworkCancellable? {
        return self.networkService.request(endpoint: endpoint) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let data):
                let result: Result<T, DataTransferError> = decode(data: data)
                DispatchQueue.main.async { return completion(result) }
            case .failure(let error):
                let error = resolve(networkError: error)
                DispatchQueue.main.async { return completion(.failure(error)) }
            }
        }
    }
    
    private func decode<T: Decodable>(data: Data?) -> Result<T, DataTransferError> {
        do {
            guard let data = data else { return .failure(.noResponse) }
            let result: T = try responseDecoder.decode(data)
            return .success(result)
        } catch {
            return .failure(.parsing(error))
        }
    }

    private func resolve(networkError error: NetworkError) -> DataTransferError {
        let resolvedError = errorHandler.handle(error: error)
        return resolvedError is NetworkError ? .networkFailure(error) : .resolvedNetworkFailure(resolvedError)
    }
}
