//
//  ResponseDecoder.swift
//  B&W
//
//  Created by Tsz-Lung on 03/04/2024.
//

import Foundation

public protocol ResponseDecoder {
    func decode<T: Decodable>(_ data: Data) throws -> T
}

// MARK: - JSONResponseDecoder

public final class JSONResponseDecoder: ResponseDecoder {
    private let jsonDecoder = JSONDecoder()
    
    public init() { }
    
    public func decode<T: Decodable>(_ data: Data) throws -> T {
        return try jsonDecoder.decode(T.self, from: data)
    }
}
