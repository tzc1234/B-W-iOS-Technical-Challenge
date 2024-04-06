import XCTest
@testable import B_W

final class ProductsListViewModelTests: XCTestCase {
    func test_init_doesNotNotifyCollaborators() {
        let (_, getProducts) = makeSUT()
        
        XCTAssertEqual(getProducts.executeCallCount, 0)
    }
    
    func test_viewDidLoad_deliversErrorOnGetProductsError() {
        let (sut, getProducts) = makeSUT()
        
        var loggedErrorMessage = [String]()
        sut.error.observe(on: self) { loggedErrorMessage.append($0) }
        
        sut.viewDidLoad()
        getProducts.complete(with: anyNSError())
        
        XCTAssertEqual(loggedErrorMessage, ["", NSLocalizedString("LOAD_PRODUCTS_ERROR", comment: "")])
    }
    
    func test_viewDidLoad_deliversErrorOnGetProductsConnectionError() {
        let (sut, getProducts) = makeSUT()
        
        var loggedErrorMessage = [String]()
        sut.error.observe(on: self) { loggedErrorMessage.append($0) }
        
        sut.viewDidLoad()
        getProducts.complete(with: DataTransferError.networkFailure(.notConnected))
        
        XCTAssertEqual(loggedErrorMessage, ["", NSLocalizedString("INTERNET_CONNECTION_ERROR", comment: "")])
    }
    
    func test_viewDidLoad_deliversEmptyProductsWhenReceivedNoProducts() {
        let emptyProducts = Products(products: [])
        let (sut, getProducts) = makeSUT()
        
        var loggedProducts = [[Product]]()
        sut.products.observe(on: self) { loggedProducts.append($0) }
        
        sut.viewDidLoad()
        getProducts.complete(with: emptyProducts)
        
        XCTAssertEqual(loggedProducts, [[], []])
    }
    
    func test_viewDidLoad_deliversItemsWhenReceivedProducts() {
        let products = Products(products: [
            makeProduct(description: nil, name: nil, price: nil),
            makeProduct(description: "some descriptions", name: "a name", price: "£100"),
            makeProduct(description: "another descriptions", name: "another name", price: "£99")
        ])
        let (sut, getProducts) = makeSUT()
        
        var loggedProducts = [[Product]]()
        sut.products.observe(on: self) { loggedProducts.append($0) }
        
        sut.viewDidLoad()
        getProducts.complete(with: products)
        
        XCTAssertEqual(loggedProducts, [[], products.products])
    }
    
    func test_didSelectItem_triggersShowProductDetails() {
        let product0 = makeProduct(id: "0")
        let product1 = makeProduct(id: "1")
        let product2 = makeProduct(id: "2")
        let products = Products(products: [product0, product1, product2])
        var loggedProducts = [Product]()
        let (sut, getProducts) = makeSUT(showProductDetails: { loggedProducts.append($0) })
        
        sut.viewDidLoad()
        getProducts.complete(with: products)
        
        sut.didSelectItem(at: 1)
        sut.didSelectItem(at: 0)
        sut.didSelectItem(at: 2)
        
        XCTAssertEqual(loggedProducts, [product1, product0, product2])
    }
    
    func test_cancelPendingLoadTask_cancelsGetProductsTaskBeforeAssignNewTask() {
        let (sut, getProducts) = makeSUT()
        
        sut.viewDidLoad()
        
        XCTAssertEqual(getProducts.cancelCallCount, 0)
        
        sut.viewDidLoad()
        
        XCTAssertEqual(getProducts.cancelCallCount, 1)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(showProductDetails: @escaping (Product) -> Void = { _ in },
                         performOnMainQueue: @escaping PerformOnMainQueue = { $0() },
                         file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: ProductsListViewModel, getProducts: GetProductsUseCaseSpy) {
        let actions = ProductsListViewModelActions(showProductDetails: showProductDetails)
        let getProducts = GetProductsUseCaseSpy()
        let sut = DefaultProductsListViewModel(
            useCase: getProducts,
            actions: actions,
            performOnMainQueue: performOnMainQueue
        )
        trackForMemoryLeaks(getProducts, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, getProducts)
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
        
        private struct GetProductsCancellable: Cancellable {
            let afterCancel: () -> Void
            
            func cancel() {
                afterCancel()
            }
        }
        
        private(set) var cancelCallCount = 0
        
        func execute(requestValue: GetProductsUseCaseRequestValue, 
                     completion: @escaping (Result<Products, Error>) -> Void) -> Cancellable? {
            executes.append(ExecuteEvent(requestValue: requestValue, completion: completion))
            return GetProductsCancellable { [weak self] in
                self?.cancelCallCount += 1
            }
        }
        
        func complete(with error: Error, at index: Int = 0) {
            executes[index].completion(.failure(error))
        }
        
        func complete(with products: Products, at index: Int = 0) {
            executes[index].completion(.success(products))
        }
    }
}
