//
//  ProductsListItemViewModelTests.swift
//  B&WTests
//
//  Created by Tsz-Lung on 04/04/2024.
//  Copyright © 2024 Artemis Simple Solutions Ltd. All rights reserved.
//

import XCTest
@testable import B_W

final class ProductsListItemViewModelTests: XCTestCase {
    func test_init_setsAllPropertiesToEmptyWhenAllNil() {
        let product = makeProduct(description: nil, name: nil, price: nil)
        let sut = makeSUT(product: product)
        
        XCTAssertEqual(sut.description, "")
        XCTAssertEqual(sut.name, "")
        XCTAssertEqual(sut.price, "")
    }
    
    func test_init_setsAllPropertiesCorrectly() {
        let product = makeProduct(description: "Some Description", name: "a name", price: "£111")
        let sut = makeSUT(product: product)
        
        XCTAssertEqual(sut.description, product.description)
        XCTAssertEqual(sut.name, product.name)
        XCTAssertEqual(sut.price, product.price)
    }
    
    func test_image_deliversImageDataAfterLoadImage() {
        let anyProduct = makeProduct(description: "Some Description", name: "a name", price: "£111")
        let expectedData = UIImage.make(withColor: .red).pngData()!
        let sut = makeSUT(product: anyProduct, loadImageData: { loadImage in
            loadImage(expectedData)
        })
        
        sut.loadImage()
        
        var loggedData = [Data?]()
        sut.image.observe(on: self) { data in
            loggedData.append(data)
        }
        
        XCTAssertEqual(loggedData, [expectedData])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(product: Product,
                         loadImageData: @escaping ProductsListItemViewModel.LoadImageData = { _ in }) -> ProductsListItemViewModel {
        ProductsListItemViewModel(product: product, loadImageData: loadImageData)
    }
    
    private func makeProduct(id: String = "id", description: String?, name: String?, price: String?) -> Product {
        Product(id: id, name: name, description: description, price: price, imagePath: nil)
    }
}
