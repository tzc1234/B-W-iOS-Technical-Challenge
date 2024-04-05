//
//  DataTransferErrorHandler.swift
//  B&W
//
//  Created by Tsz-Lung on 03/04/2024.
//

import Foundation

public protocol DataTransferErrorHandler {
    func handle(error: NetworkError) -> Error
}

public final class DefaultDataTransferErrorHandler: DataTransferErrorHandler {
    public init() { }
    public func handle(error: NetworkError) -> Error {
        return error
    }
}
