import Foundation

public protocol RequestConfig {
    var baseURL: URL { get }
}

public struct ApiRequestConfig: RequestConfig {
    public let baseURL: URL

     public init(baseURL: URL) {
        self.baseURL = baseURL
    }
}
