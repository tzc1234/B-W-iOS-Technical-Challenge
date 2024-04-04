import XCTest
@testable import B_W

final class ProductsListViewModelTests: XCTestCase {
    func test_init_doesNotNotifyCollaborators() {
        let (_, getProducts, loadImage) = makeSUT()
        
        XCTAssertEqual(getProducts.executeCallCount, 0)
        XCTAssertEqual(loadImage.loadCallCount, 0)
    }
    
    func test_viewDidLoad_deliversErrorOnGetProductsError() {
        let (sut, getProducts, _) = makeSUT()
        
        var loggedErrorMessage = [String]()
        sut.error.observe(on: self) { loggedErrorMessage.append($0) }
        
        sut.viewDidLoad()
        getProducts.complete(with: anyNSError())
        
        XCTAssertEqual(loggedErrorMessage, ["", "Failed loading products"])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(showProductDetails: @escaping (Product) -> Void = { _ in },
                         performOnMainQueue: @escaping PerformOnMainQueue = { $0() },
                         file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: ProductsListViewModel, getProducts: GetProductsUseCaseSpy, loadImage: LoadImageDataUseCaseSpy) {
        let actions = ProductsListViewModelActions(showProductDetails: showProductDetails)
        let getProducts = GetProductsUseCaseSpy()
        let loadImage = LoadImageDataUseCaseSpy()
        let sut = DefaultProductsListViewModel(
            useCase: getProducts,
            actions: actions, 
            loadImageDataUseCase: loadImage,
            performOnMainQueue: performOnMainQueue
        )
        trackForMemoryLeaks(getProducts, file: file, line: line)
        trackForMemoryLeaks(loadImage, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, getProducts, loadImage)
    }
    
    private final class GetProductsUseCaseSpy: GetProductsUseCase {
        struct ExecuteEvent {
            let requestValue: GetProductsUseCaseRequestValue
            let completion: (Result<Products, Error>) -> Void
        }
        
        private var executes = [ExecuteEvent]()
        var executeCallCount: Int {
            executes.count
        }
        
        func execute(requestValue: GetProductsUseCaseRequestValue, 
                     completion: @escaping (Result<Products, Error>) -> Void) -> Cancellable? {
            executes.append(ExecuteEvent(requestValue: requestValue, completion: completion))
            return nil
        }
        
        func complete(with error: Error, at index: Int = 0) {
            executes[index].completion(.failure(error))
        }
    }
}
