//
//  ProductDetailsViewModelTests.swift
//  B&WTests
//
//  Created by Tsz-Lung on 04/04/2024.
//

import XCTest
@testable import B_W

final class ProductDetailsViewModelTests: XCTestCase {
    func test_init_doesNotNotifyLoadImageDataUseCase() {
        let anyProduct = makeProduct(description: nil, name: nil, price: nil)
        let (_, loadImage) = makeSUT(product: anyProduct)
        
        XCTAssertEqual(loadImage.loadCallCount, 0)
    }
    
    func test_init_setsAllPropertiesCorrectlyWhenAllNil() {
        let nilPropertiesProduct = makeProduct(description: nil, name: nil, price: nil)
        let (sut, _) = makeSUT(product: nilPropertiesProduct)
        
        XCTAssertEqual(sut.name, "")
        XCTAssertEqual(sut.description, "")
        XCTAssertEqual(sut.price, "")
    }
    
    func test_init_setsAllPropertiesCorrectly() {
        let product = makeProduct(description: "some description", name: "a name", price: "£111")
        let (sut, _) = makeSUT(product: product)
        
        XCTAssertEqual(sut.name, product.name)
        XCTAssertEqual(sut.description, product.description)
        XCTAssertEqual(sut.price, product.price)
    }
    
    func test_updateImage_ignoresWhenInvalidImagePath() {
        let product = makeProduct(imagePath: " : ")
        let (sut, loadImage) = makeSUT(product: product)
        
        sut.updateImage()
        
        XCTAssertEqual(loadImage.loadCallCount, 0)
    }
    
    func test_updateImage_ignoresWhenEmptyImagePath() {
        let product = makeProduct(imagePath: "")
        let (sut, loadImage) = makeSUT(product: product)
        
        sut.updateImage()
        
        XCTAssertEqual(loadImage.loadCallCount, 0)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(product: Product,
                         file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: DefaultProductDetailsViewModel, loadImage: LoadImageDataUseCaseSpy) {
        let loadImage = LoadImageDataUseCaseSpy()
        let sut = DefaultProductDetailsViewModel(product: product, loadImageDataUseCase: loadImage)
        trackForMemoryLeaks(loadImage, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loadImage)
    }
    
    private class LoadImageDataUseCaseSpy: LoadImageDataUseCase {
        private struct LoadImageCancellable: Cancellable {
            func cancel() {}
        }
        
        private(set) var loadCallCount = 0
        
        func load(for url: URL, completion: @escaping Completion) -> Cancellable {
            loadCallCount += 1
            return LoadImageCancellable()
        }
    }
}
