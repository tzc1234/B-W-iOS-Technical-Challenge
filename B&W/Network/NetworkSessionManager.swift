//
//  NetworkSessionManager.swift
//  B&W
//
//  Created by Tsz-Lung on 03/04/2024.
//  Copyright © 2024 Artemis Simple Solutions Ltd. All rights reserved.
//

import Foundation

public protocol NetworkSessionManager {
    typealias CompletionHandler = (Data?, URLResponse?, Error?) -> Void

    func request(_ request: URLRequest, completion: @escaping CompletionHandler) -> NetworkCancellable
}

public class DefaultNetworkSessionManager: NetworkSessionManager {
    public init() {}
    public func request(_ request: URLRequest,
                        completion: @escaping CompletionHandler) -> NetworkCancellable {
        let task = URLSession.shared.dataTask(with: request, completionHandler: completion)
        task.resume()
        return task
    }
}

extension URLSessionTask: NetworkCancellable { }
