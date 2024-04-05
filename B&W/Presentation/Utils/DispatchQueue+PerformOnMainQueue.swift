//
//  DispatchQueue+PerformOnMainQueue.swift
//  B&W
//
//  Created by Tsz-Lung on 05/04/2024.
//

import Foundation

public typealias PerformOnMainQueue = (@escaping () -> Void) -> Void

extension DispatchQueue {
    public static func performOnMainQueue() -> PerformOnMainQueue {
        { action in
            DispatchQueue.main.async { action() }
        }
    }
}
