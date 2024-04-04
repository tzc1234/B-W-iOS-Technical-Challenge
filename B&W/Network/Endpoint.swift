import Foundation

public enum HTTPMethodType: String {
    case get = "GET"
}

// Move the Requestable extension functions to Endpoint extension,
// therefore variables(path, isFullPath, method) needn't to be exposed from Requestable.
public protocol Requestable {
    func urlRequest(with config: RequestConfig) throws -> URLRequest
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

    public let path: String
    public let isFullPath: Bool
    public let method: HTTPMethodType
    public let responseDecoder: ResponseDecoder

    init(path: String,
         isFullPath: Bool = false,
         method: HTTPMethodType,
         responseDecoder: ResponseDecoder = JSONResponseDecoder()) {
        self.path = path
        self.isFullPath = isFullPath
        self.method = method
        self.responseDecoder = responseDecoder
    }
}

extension Endpoint {
    public func urlRequest(with config: RequestConfig) throws -> URLRequest {
        let url = try url(with: config)
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        return urlRequest
    }
    
    private func url(with config: RequestConfig) throws -> URL {
        let baseURL = config.baseURL.absoluteString.last != "/" ? config.baseURL.absoluteString + "/" : config.baseURL.absoluteString
        let endpoint = isFullPath ? path : baseURL.appending(path)

        guard let urlComponents = URLComponents(string: endpoint) else { throw RequestError.componentsError }
        guard let url = urlComponents.url else { throw RequestError.componentsError }

        return url
    }
}
