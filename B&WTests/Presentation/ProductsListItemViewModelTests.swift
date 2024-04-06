//
//  ProductsListItemViewModelTests.swift
//  B&WTests
//
//  Created by Tsz-Lung on 04/04/2024.
//

import XCTest
@testable import B_W

final class ProductsListItemViewModelTests: XCTestCase {
    func test_init_setsAllPropertiesToEmptyWhenAllNil() {
        let product = makeProduct(description: nil, name: nil, price: nil)
        let (sut, _) = makeSUT(product: product)
        
        XCTAssertEqual(sut.description, "")
        XCTAssertEqual(sut.name, "")
        XCTAssertEqual(sut.price, "")
    }
    
    func test_init_setsAllPropertiesCorrectly() {
        let product = makeProduct(description: "Some Description", name: "a name", price: "£111")
        let (sut, _) = makeSUT(product: product)
        
        XCTAssertEqual(sut.description, product.description)
        XCTAssertEqual(sut.name, product.name)
        XCTAssertEqual(sut.price, product.price)
    }
    
    func test_image_ignoresWhenNilImagePath() {
        let nilImagePathProduct = makeProduct(imagePath: nil)
        let (sut, loadImage) = makeSUT(product: nilImagePathProduct)
        
        var loggedData = [Data?]()
        sut.image.observe(on: self) { loggedData.append($0) }
        sut.loadImage()
        
        XCTAssertEqual(loadImage.loadCallCount, 0)
    }
    
    func test_image_ignoresOnLoadImageError() {
        let withImagePathProduct = makeProduct(imagePath: anyURL())
        let (sut, loadImage) = makeSUT(product: withImagePathProduct)
        
        var loggedData = [Data?]()
        sut.image.observe(on: self) { loggedData.append($0) }
        sut.loadImage()
        loadImage.complete(with: anyNSError())
        
        XCTAssertEqual(loggedData, [nil])
    }
    
    func test_image_deliversImageDataAfterLoadImage() {
        let withImagePathProduct = makeProduct(imagePath: anyURL())
        let expectedData = UIImage.make(withColor: .red).pngData()!
        let (sut, loadImage) = makeSUT(product: withImagePathProduct)
        
        var loggedData = [Data?]()
        sut.image.observe(on: self) { loggedData.append($0) }
        sut.loadImage()
        loadImage.complete(with: expectedData)
        
        XCTAssertEqual(loggedData, [nil, expectedData])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(product: Product,
                         performOnMainQueue: @escaping PerformOnMainQueue = { $0() },
                         file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: ProductsListItemViewModel, loadImage: LoadImageDataUseCaseSpy) {
        let loadImage = LoadImageDataUseCaseSpy()
        let sut = ProductsListItemViewModel(
            product: product,
            loadImageDataUseCase: loadImage,
            performOnMainQueue: performOnMainQueue
        )
        trackForMemoryLeaks(loadImage, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loadImage)
    }
}
