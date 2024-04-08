//
//  DispatchOnMainQueueDecorator.swift
//  B&W
//
//  Created by Tsz-Lung on 08/04/2024.
//

import Foundation

final class DispatchOnMainQueueDecorator<T> {
    let decoratee: T
    let performOnMainQueue: PerformOnMainQueue
    
    init(decoratee: T,
         performOnMainQueue: @escaping PerformOnMainQueue = DispatchQueue.performOnMainQueue()) {
        self.decoratee = decoratee
        self.performOnMainQueue = performOnMainQueue
    }
}

extension DispatchOnMainQueueDecorator: NetworkService where T == NetworkService {
    func request(endpoint: Requestable, completion: @escaping NetworkService.CompletionHandler) -> NetworkCancellable? {
        return decoratee.request(endpoint: endpoint) { [weak self] result in
            self?.performOnMainQueue {
                completion(result)
            }
        }
    }
}
