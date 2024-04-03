//
//  ResponseDecoder.swift
//  B&W
//
//  Created by Tsz-Lung on 03/04/2024.
//  Copyright © 2024 Artemis Simple Solutions Ltd. All rights reserved.
//

import Foundation

public protocol ResponseDecoder {
    func decode<T: Decodable>(_ data: Data) throws -> T
}

// MARK: - JSONResponseDecoder

public class JSONResponseDecoder: ResponseDecoder {
    private let jsonDecoder = JSONDecoder()
    
    public func decode<T: Decodable>(_ data: Data) throws -> T {
        return try jsonDecoder.decode(T.self, from: data)
    }
}

// MARK: - RawDataResponseDecoder

public class RawDataResponseDecoder: ResponseDecoder {
    public init() { }

    enum CodingKeys: String, CodingKey {
        case `default` = ""
    }
    
    public func decode<T: Decodable>(_ data: Data) throws -> T {
        if T.self is Data.Type, let data = data as? T {
            return data
        } else {
            let context = DecodingError.Context(codingPath: [CodingKeys.default], debugDescription: "Expected Data type")
            throw Swift.DecodingError.typeMismatch(T.self, context)
        }
    }
}
