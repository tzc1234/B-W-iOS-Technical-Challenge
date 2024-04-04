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
    let error: Observable<String>

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
    private let loadImageDataUseCase: LoadImageDataUseCase
    
    init(useCase: GetProductsUseCase,
         actions: ProductsListViewModelActions,
         loadImageDataUseCase: LoadImageDataUseCase,
         performOnMainQueue: @escaping PerformOnMainQueue = { action in
            DispatchQueue.main.async { action() }
    }) {
        self.useCase = useCase
        self.actions = actions
        self.loadImageDataUseCase = loadImageDataUseCase
        self.error = Observable("", performOnMainQueue: performOnMainQueue)
    }
    
    private func load(productQuery: ProductQuery) {
        query = productQuery.query

        loadTask = useCase.execute(
            requestValue: .init(query: productQuery),
            completion: { [weak self] result in
                guard let self else { return }
                
                switch result {
                case .success(let data):
                    self.products = data.products
                    self.items.value = data.products.map(self.makeProductsListItemViewModel)
                case .failure(let error):
                    self.error.value = error.isInternetConnectionError ?
                        NSLocalizedString("No internet connection", comment: "") :
                        NSLocalizedString("Failed loading products", comment: "")
                }
        })
    }
    
    private func makeProductsListItemViewModel(product: Product) -> ProductsListItemViewModel {
        ProductsListItemViewModel(product: product) { [weak self] loadImageData in
            guard let imagePath = product.imagePath, let url = URL(string: imagePath) else { return }
            
            // The actual image data loading logic for ProductsListItemViewModel.
            _ = self?.loadImageDataUseCase.load(for: url) { result in
                switch result {
                case let .success(data):
                    loadImageData(data)
                case .failure:
                    break
                }
            }
        }
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
