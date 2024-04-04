//
//  ProductsDependenciesContainerTests.swift
//  B&WTests
//
//  Created by Tsz-Lung on 04/04/2024.
//  Copyright © 2024 Artemis Simple Solutions Ltd. All rights reserved.
//

import XCTest
@testable import B_W

final class ProductsDependenciesContainerTests: XCTestCase {
    func test_makeProductsListViewController_deliversProductsListViewControllerSuccessfully() {
        let sut = makeSUT()
        let actions = ProductsListViewModelActions(showProductDetails: { _ in })
        
        let controller: ProductsListViewController = sut.makeProductsListViewController(actions: actions)
        
        XCTAssertNotNil(controller)
    }
    
    func test_makeProductDetailsViewController_deliversProductDetailsViewControllerSuccessfully() {
        let sut = makeSUT()
        let product = Product(id: "id", name: nil, description: nil, price: nil, imagePath: nil)
        
        let controller: ProductDetailsViewController = sut.makeProductDetailsViewController(product: product)
        
        XCTAssertNotNil(controller)
    }
    
    // MARK: Helpers
    
    private func makeSUT(baseURL: URL = URL(string: "https://base-url.com")!) -> ProductsDependenciesContainer {
        let config = ConfigStub(baseURL: baseURL)
        return ProductsDependenciesContainer(config: config, dataTransferService: DummyDataTransferService())
    }
    
    private class DummyDataTransferService: DataTransferService {
        struct Cancellable: NetworkCancellable {
            func cancel() {}
        }
        
        func request<T: Decodable, E: ResponseRequestable>(with endpoint: E,
                                                           completion: @escaping CompletionHandler<T>) -> NetworkCancellable? where E.Response == T {
            Cancellable()
        }
    }
}
