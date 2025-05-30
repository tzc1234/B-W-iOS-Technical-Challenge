import Foundation

public enum HTTPMethodType: String {
    case get = "GET"
}

// Move the Requestable extension functions to Endpoint extension,
// therefore variables(path, isFullPath, method) needn't to be exposed from Requestable.
public protocol Requestable {
    func urlRequest() throws -> URLRequest
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
    private let method: HTTPMethodType

    public init(config: RequestConfig, path: String, method: HTTPMethodType) {
        self.config = config
        self.path = path
        self.method = method
    }
}

// Move config from method injection to constructor injection.
// Config shouldn't change frequently, if config has to be changed, I would rather create a new one.
extension Endpoint: Requestable {
    public func urlRequest() throws -> URLRequest {
        var urlRequest = URLRequest(url: try url())
        urlRequest.httpMethod = method.rawValue
        return urlRequest
    }
    
    private func url() throws -> URL {
        let endpoint = config.baseURL.appendingPathComponent(path)
        guard let url = URLComponents(url: endpoint, resolvingAgainstBaseURL: true)?.url else {
            throw RequestError.componentsError
        }

        return url
    }
}
