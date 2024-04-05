//
//  Cancellable.swift
//  B&W
//
//  Created by Tsz-Lung on 05/04/2024.
//

import Foundation

// Cancellable protocol should live in Domain. Since the repositories and use cases are depending on it directly.
public protocol Cancellable {
    func cancel()
}
