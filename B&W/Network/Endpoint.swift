import Foundation

public enum HTTPMethod: String {
    case get = "GET"
}

// Move the Requestable extension functions to Endpoint extension,
// therefore variables(path, isFullPath, method) needn't to be exposed from Requestable.
public protocol Requestable {
    func urlRequest() -> URLRequest
}

public enum RequestError: Error {
    case componentsError
}

// Endpoint should not hold the reference of ResponseDecoder and also define the Response generic type 
// because Endpoint itself doesn't need them.

// Endpoint is a tiny struct now.
public struct Endpoint {
    private let config: RequestConfig
    private let path: String
    private let method: HTTPMethod

    public init(config: RequestConfig, path: String, method: HTTPMethod) {
        self.config = config
        self.path = path
        self.method = method
    }
}

// Move config from method injection to constructor injection.
// Config shouldn't change frequently, if config has to be changed, I would rather create a new one.
extension Endpoint: Requestable {
    public func urlRequest() -> URLRequest {
        var urlRequest = URLRequest(url: url())
        urlRequest.httpMethod = method.rawValue
        return urlRequest
    }
    
    private func url() -> URL {
        config.baseURL.appendingPathComponent(path)
    }
}
