//
//  ProductsEndpoints.swift
//  B&W
//
//  Created by Tsz-Lung on 04/04/2024.
//

import Foundation

/// The collection of products end points required by ProductsRepository.
protocol ProductsEndpoints {
    func getProducts() -> Endpoint<ProductResponseDTO>
}

struct ProductsRepositoryEndpoints: ProductsEndpoints {
    private let config: RequestConfig
    
    init(config: RequestConfig) {
        self.config = config
    }
    
    func getProducts() -> Endpoint<ProductResponseDTO> {
        // Inject config into Endpoint from here.
        Endpoint(config: config, path: "db", method: .get)
    }
}
