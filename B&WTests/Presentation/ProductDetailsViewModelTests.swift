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
    
    func test_updateImage_ignoresWhenNilImagePath() {
        let product = makeProduct(imagePath: nil)
        let (sut, loadImage) = makeSUT(product: product)
        
        sut.updateImage()
        
        XCTAssertEqual(loadImage.loadCallCount, 0)
    }
    
    func test_updateImage_doesNotDeliverDataOnLoadImageDataError() {
        let url = anyURL()
        let product = makeProduct(imagePath: url)
        let (sut, loadImage) = makeSUT(product: product)
        
        var loggedData = [Data?]()
        sut.image.observe(on: self) { data in
            loggedData.append(data)
        }
        
        sut.updateImage()
        loadImage.complete(with: anyNSError())
        
        XCTAssertEqual(loggedData, [nil])
        XCTAssertEqual(loadImage.urls, [url])
    }
    
    func test_updateImage_deliversDataWhenReceivedDataFromLoadImageDataUseCase() {
        let url = anyURL()
        let product = makeProduct(imagePath: url)
        let (sut, loadImage) = makeSUT(product: product)
        let expectedData = UIImage.make(withColor: .gray).pngData()!
        
        var loggedData = [Data?]()
        sut.image.observe(on: self) { data in
            loggedData.append(data)
        }
        
        sut.updateImage()
        loadImage.complete(with: expectedData)
        
        XCTAssertEqual(loggedData, [nil, expectedData])
        XCTAssertEqual(loadImage.urls, [url])
    }
    
    func test_cancelImageLoading_cancelsLoadImageDataProperly() {
        let product = makeProduct(imagePath: anyURL())
        let (sut, loadImage) = makeSUT(product: product)
        
        sut.updateImage()
        
        XCTAssertEqual(loadImage.cancelCallCount, 0)
        
        sut.cancelImageLoading()
        
        XCTAssertEqual(loadImage.cancelCallCount, 1)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(product: Product,
                         file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: ProductDetailsViewModel, loadImage: LoadImageDataUseCaseSpy) {
        let loadImage = LoadImageDataUseCaseSpy()
        let sut = DefaultProductDetailsViewModel(
            product: product,
            loadImageDataUseCase: loadImage
        )
        trackForMemoryLeaks(loadImage, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loadImage)
    }
}
