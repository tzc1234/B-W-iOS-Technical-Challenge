//
//  CommonHelpers.swift
//  B&WTests
//
//  Created by Tsz-Lung on 04/04/2024.
//  Copyright © 2024 Artemis Simple Solutions Ltd. All rights reserved.
//

import Foundation
@testable import B_W

func makeProduct(id: String = "id",
                 description: String?,
                 name: String?,
                 price: String?,
                 imagePath: String? = nil) -> Product {
    Product(id: id, name: name, description: description, price: price, imagePath: imagePath)
}
