//
//  HTTPClient.swift
//  B&W
//
//  Created by Tsz-Lung on 28/04/2024.
//

import Foundation

public protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    
    func request(_ request: URLRequest, completion: @escaping (Result) -> Void) -> HTTPClientTask
}

public protocol HTTPClientTask {
    func cancel()
}

public final class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    
    public init(session: URLSession) {
        self.session = session
    }
    
    struct UnexpectedRepresentationError: Error {}
    
    private struct Wrapper: HTTPClientTask {
        let task: URLSessionTask
        
        func cancel() {
            task.cancel()
        }
    }
    
    public func request(_ request: URLRequest, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        let task = session.dataTask(with: request) { data, response, error in
            if let data, let httpResponse = response as? HTTPURLResponse {
                completion(.success((data, httpResponse)))
            } else if let error {
                completion(.failure(error))
            } else {
                completion(.failure(UnexpectedRepresentationError()))
            }
        }
        task.resume()
        return Wrapper(task: task)
    }
}
