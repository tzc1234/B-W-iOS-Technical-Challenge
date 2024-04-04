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

enum RequestError: Error {
    case componentsError
}

public class Endpoint<R>: ResponseRequestable {
    public typealias Response = R

    private let config: RequestConfig
    private let path: String
    private let isFullPath: Bool
    private let method: HTTPMethodType
    public let responseDecoder: ResponseDecoder

    init(config: RequestConfig,
         path: String,
         isFullPath: Bool = false,
         method: HTTPMethodType,
         responseDecoder: ResponseDecoder = JSONResponseDecoder()) {
        self.config = config
        self.path = path
        self.isFullPath = isFullPath
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
        let baseURL = config.baseURL.absoluteString.last != "/" ? config.baseURL.absoluteString + "/" : config.baseURL.absoluteString
        let endpoint = isFullPath ? path : baseURL.appending(path)

        guard let urlComponents = URLComponents(string: endpoint) else { throw RequestError.componentsError }
        guard let url = urlComponents.url else { throw RequestError.componentsError }

        return url
    }
}
