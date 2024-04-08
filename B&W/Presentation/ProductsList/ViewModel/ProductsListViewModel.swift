import Foundation

struct ProductsListViewModelActions {
    let showProductDetails: (Product) -> Void
}

protocol ProductsListViewModelInput {
    func viewDidLoad()
    func didSelectItem(at index: Int)
}

protocol ProductsListViewModelOutput {
    var products: Observable<[Product]> { get }
    var error: Observable<String> { get }
}

typealias ProductsListViewModel = ProductsListViewModelInput & ProductsListViewModelOutput

final class DefaultProductsListViewModel: ProductsListViewModel {
    
    // MARK: - OUTPUT

    let products: Observable<[Product]>
    let error: Observable<String>

    // I guess the view will update this query when choosing different filters in real scenario.
    // Although it's not used in this challenge.
    var query: String = ""
    
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
        self.products = Observable([])
        self.error = Observable("")
    }
    
    private func load(with refinement: Refinement) {
        query = refinement.query

        loadTask = useCase.getProducts(
            with: refinement,
            completion: { [weak self] result in
                guard let self else { return }
                
                switch result {
                case .success(let data):
                    self.products.value = data.products
                case .failure(let error):
                    self.error.value = error.isInternetConnectionError ?
                        NSLocalizedString("INTERNET_CONNECTION_ERROR", comment: "") :
                        NSLocalizedString("LOAD_PRODUCTS_ERROR", comment: "")
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
        load(with: Refinement(query: query))
    }

    func didSelectItem(at index: Int) {
        actions.showProductDetails(products.value[index])
    }
}
