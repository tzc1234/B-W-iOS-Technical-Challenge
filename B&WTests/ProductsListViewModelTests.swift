import XCTest
@testable import B_W

final class ProductsListViewModelTests: XCTestCase {
    func test_init_doesNotNotifyCollaborators() {
        let (_, getProducts, loadImage) = makeSUT()
        
        XCTAssertEqual(getProducts.executeCallCount, 0)
        XCTAssertEqual(loadImage.loadCallCount, 0)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(showProductDetails: @escaping (Product) -> Void = { _ in },
                         file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: ProductsListViewModel, getProducts: GetProductsUseCaseSpy, loadImage: LoadImageDataUseCaseSpy) {
        let actions = ProductsListViewModelActions(showProductDetails: showProductDetails)
        let getProducts = GetProductsUseCaseSpy()
        let loadImage = LoadImageDataUseCaseSpy()
        let sut = DefaultProductsListViewModel(
            useCase: getProducts,
            actions: actions, 
            loadImageDataUseCase: loadImage
        )
        trackForMemoryLeaks(getProducts, file: file, line: line)
        trackForMemoryLeaks(loadImage, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, getProducts, loadImage)
    }
    
    private final class GetProductsUseCaseSpy: GetProductsUseCase {
        private(set) var executeCallCount = 0
        
        func execute(requestValue: GetProductsUseCaseRequestValue, completion: @escaping (Result<Products, any Error>) -> Void) -> Cancellable? {
            executeCallCount += 1
            return nil
        }
    }
}
