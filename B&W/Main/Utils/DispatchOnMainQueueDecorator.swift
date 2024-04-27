//
//  DispatchOnMainQueueDecorator.swift
//  B&W
//
//  Created by Tsz-Lung on 08/04/2024.
//

import Foundation

final class DispatchOnMainQueueDecorator<T> {
    let decoratee: T
    
    init(decoratee: T) {
        self.decoratee = decoratee
    }
    
    func performOnMainQueue(action: @escaping () -> Void) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { action() }
            return
        }
        
        action()
    }
}

extension DispatchOnMainQueueDecorator: NetworkService where T == NetworkService {
    func request(endpoint: Requestable, completion: @escaping NetworkService.CompletionHandler) -> NetworkCancellable {
        return decoratee.request(endpoint: endpoint) { [weak self] result in
            self?.performOnMainQueue {
                completion(result)
            }
        }
    }
}
