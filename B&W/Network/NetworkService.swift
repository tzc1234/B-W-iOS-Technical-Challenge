import Foundation

public enum NetworkError: Error {
    case error(statusCode: Int, data: Data?)
    case notConnected
    case cancelled
    case generic
}

public protocol NetworkCancellable {
    func cancel()
}

public protocol NetworkService {
    typealias CompletionHandler = (Result<Data?, NetworkError>) -> Void

    func request(endpoint: Requestable, completion: @escaping CompletionHandler) -> NetworkCancellable
}

// No need to carry a RequestConfig for Endpoint.
public final class DefaultNetworkService {
    private let sessionManager: NetworkSessionManager

    public init(sessionManager: NetworkSessionManager = DefaultNetworkSessionManager()) {
        self.sessionManager = sessionManager
    }

    private func request(request: URLRequest, completion: @escaping CompletionHandler) -> NetworkCancellable {
        let sessionDataTask = sessionManager.request(request) { [weak self] data, response, requestError in
            guard let self else { return }
            
            if let requestError {
                var error: NetworkError
                if let response = response as? HTTPURLResponse {
                    error = .error(statusCode: response.statusCode, data: data)
                } else {
                    error = resolve(error: requestError)
                }

                completion(.failure(error))
            } else {
                completion(.success(data))
            }
        }

        return sessionDataTask
    }

    private func resolve(error: Error) -> NetworkError {
        let code = URLError.Code(rawValue: (error as NSError).code)
        switch code {
        case .notConnectedToInternet: return .notConnected
        case .cancelled: return .cancelled
        default: return .generic
        }
    }
}

extension DefaultNetworkService: NetworkService {
    public func request(endpoint: Requestable, completion: @escaping CompletionHandler) -> NetworkCancellable {
        let urlRequest = endpoint.urlRequest()
        return request(request: urlRequest, completion: completion)
    }
}
