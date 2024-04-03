import Foundation

struct ProductsListViewModelActions {
    let showProductDetails: (Product) -> Void
}

protocol ProductsListViewModelInput {
    func viewDidLoad()
    func didSelectItem(at index: Int)
}

protocol ProductsListViewModelOutput {
    var items: Observable<[ProductsListItemViewModel]> { get }
    var error: Observable<String> { get }
}

typealias ProductsListViewModel = ProductsListViewModelInput & ProductsListViewModelOutput

final class DefaultProductsListViewModel: ProductsListViewModel {
    
    // MARK: - OUTPUT

    let items: Observable<[ProductsListItemViewModel]> = Observable([])
    let error: Observable<String> = Observable("")

    private var query: String = "" // Set query to private, since it needn't to be exposed.
    private var products: [Product] = [] // Set products to private, since it needn't to be exposed.
    private var loadTask: Cancellable? {
        willSet {
            // State the intention precisely.
            cancelCurrentPendingTaskBeforeAssigningNewTask()
        }
    }

    private let useCase: GetProductsUseCase
    private let actions: ProductsListViewModelActions
    
    init(useCase: GetProductsUseCase, actions: ProductsListViewModelActions) {
        self.useCase = useCase
        self.actions = actions
    }
    
    private func load(productQuery: ProductQuery) {
        query = productQuery.query

        loadTask = useCase.execute(
            requestValue: .init(query: productQuery),
            completion: { result in
                switch result {
                case .success(let data):
                    self.products = data.products
                    self.items.value = data.products.map(ProductsListItemViewModel.init)
                case .failure(let error):
                    self.error.value = error.isInternetConnectionError ?
                        NSLocalizedString("No internet connection", comment: "") :
                        NSLocalizedString("Failed loading products", comment: "")
                }
        })
    }
    
    private func cancelCurrentPendingTaskBeforeAssigningNewTask() {
        loadTask?.cancel()
    }
}

// MARK: - INPUT. View event methods

extension DefaultProductsListViewModel {
    func viewDidLoad() {
        load(productQuery: .init(query: query))
    }

    func didSelectItem(at index: Int) {
        actions.showProductDetails(products[index])
    }
}
