//
//  CommonHelpers.swift
//  B&WTests
//
//  Created by Tsz-Lung on 04/04/2024.
//

import Foundation
@testable import B_W

func makeProduct(id: String = "id",
                 description: String? = nil,
                 name: String? = nil,
                 price: String? = nil,
                 imagePath: String? = nil) -> Product {
    Product(id: id, name: name, description: description, price: price, imagePath: imagePath)
}

func anyURL() -> URL {
    URL(string: "https://any-url.com")!
}
