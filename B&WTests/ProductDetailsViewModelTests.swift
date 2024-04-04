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
    
    func test_updateImage_doesNotDeliverDataOnLoadImageDataError() {
        let url = anyURL()
        let product = makeProduct(imagePath: url.absoluteString)
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
    
    // MARK: - Helpers
    
    private func makeSUT(product: Product,
                         performOnMainQueue: @escaping PerformOnMainQueue = { $0() },
                         file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: DefaultProductDetailsViewModel, loadImage: LoadImageDataUseCaseSpy) {
        let loadImage = LoadImageDataUseCaseSpy()
        let sut = DefaultProductDetailsViewModel(
            product: product,
            loadImageDataUseCase: loadImage,
            performOnMainQueue: performOnMainQueue
        )
        trackForMemoryLeaks(loadImage, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loadImage)
    }
    
    private func anyNSError() -> NSError {
        NSError(domain: "error", code: 0)
    }
    
    private class LoadImageDataUseCaseSpy: LoadImageDataUseCase {
        struct Load {
            let url: URL
            let completion: Completion
        }
        
        private struct LoadImageCancellable: Cancellable {
            func cancel() {}
        }
        
        private var loads = [Load]()
        var loadCallCount: Int {
            loads.count
        }
        var urls: [URL] {
            loads.map(\.url)
        }
        
        func load(for url: URL, completion: @escaping Completion) -> Cancellable {
            loads.append(Load(url: url, completion: completion))
            return LoadImageCancellable()
        }
        
        func complete(with error: Error, at index: Int = 0) {
            loads[index].completion(.failure(error))
        }
    }
}
