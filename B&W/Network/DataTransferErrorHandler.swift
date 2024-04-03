//
//  DataTransferErrorHandler.swift
//  B&W
//
//  Created by Tsz-Lung on 03/04/2024.
//  Copyright © 2024 Artemis Simple Solutions Ltd. All rights reserved.
//

import Foundation

public protocol DataTransferErrorHandler {
    func handle(error: NetworkError) -> Error
}

public class DefaultDataTransferErrorHandler: DataTransferErrorHandler {
    public init() { }
    public func handle(error: NetworkError) -> Error {
        return error
    }
}
