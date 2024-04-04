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
    
    func test_viewDidLoad_deliversErrorOnGetProductsConnectionError() {
        let (sut, getProducts, _) = makeSUT()
        
        var loggedErrorMessage = [String]()
        sut.error.observe(on: self) { loggedErrorMessage.append($0) }
        
        sut.viewDidLoad()
        getProducts.complete(with: DataTransferError.networkFailure(.notConnected))
        
        XCTAssertEqual(loggedErrorMessage, ["", "No internet connection"])
    }
    
    func test_viewDidLoad_deliversEmptyItemsWhenReceivedNoProducts() {
        let emptyProducts = Products(products: [])
        let (sut, getProducts, _) = makeSUT()
        
        var loggedItems = [[ProductsListItemViewModel]]()
        sut.items.observe(on: self) { loggedItems.append($0) }
        
        sut.viewDidLoad()
        getProducts.complete(with: emptyProducts)
        
        XCTAssertEqual(loggedItems, [[], []])
    }
    
    func test_viewDidLoad_deliversItemsWhenReceivedProducts() {
        let products = Products(products: [
            makeProduct(description: nil, name: nil, price: nil),
            makeProduct(description: "some descriptions", name: "a name", price: "£100"),
            makeProduct(description: "another descriptions", name: "another name", price: "£99")
        ])
        let (sut, getProducts, _) = makeSUT()
        
        var loggedItems = [[ProductsListItemViewModel]]()
        sut.items.observe(on: self) { loggedItems.append($0) }
        
        sut.viewDidLoad()
        getProducts.complete(with: products)
        
        XCTAssertEqual(loggedItems.count, 2)
        XCTAssertEqual(loggedItems[0], [])
        assert(items: loggedItems[1], asExpectedProducts: products)
    }
    
    func test_itemLoadImage_ignoresWhenInvalidImagePath() {
        let product = makeProduct(imagePath: " : ")
        let (sut, getProducts, loadImage) = makeSUT()
        
        let item = extractItem(from: sut, with: getProducts, and: product)
        item.loadImage()
        
        XCTAssertEqual(loadImage.loadCallCount, 0)
    }
    
    func test_itemLoadImage_ignoresWhenEmptyImagePath() {
        let product = makeProduct(imagePath: "")
        let (sut, getProducts, loadImage) = makeSUT()
        
        let item = extractItem(from: sut, with: getProducts, and: product)
        item.loadImage()
        
        XCTAssertEqual(loadImage.loadCallCount, 0)
    }
    
    func test_itemLoadImage_doesNotDeliverDataOnLoadImageDataError() {
        let url = anyURL()
        let product = makeProduct(imagePath: url.absoluteString)
        let (sut, getProducts, loadImage) = makeSUT()
        
        let item = extractItem(from: sut, with: getProducts, and: product)
        item.loadImage()
        
        XCTAssertEqual(loadImage.loadCallCount, 1)
        
        var loggedData = [Data?]()
        item.image.observe(on: self) { data in
            loggedData.append(data)
        }
        loadImage.complete(with: anyNSError())
        
        XCTAssertEqual(loggedData, [nil])
        XCTAssertEqual(loadImage.urls, [url])
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
    
    private func extractItem(from sut: ProductsListViewModel,
                             with getProducts: GetProductsUseCaseSpy,
                             and product: Product) -> ProductsListItemViewModel {
        var loggedItems = [[ProductsListItemViewModel]]()
        sut.items.observe(on: self) { loggedItems.append($0) }
        sut.viewDidLoad()
        getProducts.complete(with: Products(products: [product]))
        
        return loggedItems[1].first!
    }
    
    private func assert(items: [ProductsListItemViewModel], 
                        asExpectedProducts expectedProducts: Products,
                        file: StaticString = #filePath,
                        line: UInt = #line) {
        let products = expectedProducts.products
        guard products.count == items.count else {
            XCTFail("Item count: \(items.count) not match expected product count: \(products.count)", file: file, line: line)
            return
        }
        
        items.enumerated().forEach { index, item in
            let product = products[index]
            XCTAssertEqual(item.name, product.name ?? "", "item(\(index) name not matched", file: file, line: line)
            XCTAssertEqual(item.description, product.description ?? "", "item(\(index) name not matched", file: file, line: line)
            XCTAssertEqual(item.price, product.price ?? "", "item(\(index) name not matched", file: file, line: line)
        }
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
        
        func complete(with products: Products, at index: Int = 0) {
            executes[index].completion(.success(products))
        }
    }
}
