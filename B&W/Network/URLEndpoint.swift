//
//  URLEndpoint.swift
//  B&W
//
//  Created by Tsz-Lung on 05/04/2024.
//

import Foundation

// I only need a tiny little component to fulfil my purpose: convert URL to URLRequest. A simple struct will do.
// The original Endpoint is a bit too much in this case.
public struct URLEndpoint: Requestable {
    private let url: URL
    
    public init(url: URL) {
        self.url = url
    }
    
    public func urlRequest() throws -> URLRequest {
        URLRequest(url: url)
    }
}
