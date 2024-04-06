import Foundation

public enum HTTPMethodType: String {
    case get = "GET"
}

// Move the Requestable extension functions to Endpoint extension,
// therefore variables(path, isFullPath, method) needn't to be exposed from Requestable.
public protocol Requestable {
    func urlRequest() throws -> URLRequest
}

public protocol ResponseRequestable: Requestable {
    associatedtype Response

    var responseDecoder: ResponseDecoder { get }
}

public enum RequestError: Error {
    case componentsError
}

public final class Endpoint<R>: ResponseRequestable {
    public typealias Response = R

    private let config: RequestConfig
    private let path: String
    private let method: HTTPMethodType
    public let responseDecoder: ResponseDecoder

    public init(config: RequestConfig,
                path: String,
                method: HTTPMethodType,
                responseDecoder: ResponseDecoder = JSONResponseDecoder()) {
        self.config = config
        self.path = path
        self.method = method
        self.responseDecoder = responseDecoder
    }
}

// Move config from method injection to constructor injection.
// Config shouldn't change frequently, if config has to be changed, I would rather create a new one.
extension Endpoint {
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
