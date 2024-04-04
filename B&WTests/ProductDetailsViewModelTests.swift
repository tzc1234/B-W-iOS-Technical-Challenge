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
