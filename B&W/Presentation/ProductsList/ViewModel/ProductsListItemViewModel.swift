import Foundation

struct ProductsListItemViewModel {
    typealias LoadImageData = (@escaping (Data) -> Void) -> Void
    
    let image: Observable<Data?>
    
    let name: String
    let price: String
    let description: String
    
    // Holding a image Data callback closure injected from DefaultProductsListViewModel.
    private let loadImageData: LoadImageData
    
    init(product: Product,
         loadImageData: @escaping LoadImageData,
         performOnMain: @escaping (@escaping () -> Void) -> Void = { action in
            DispatchQueue.main.async { action() }
    }) {
        self.name = product.name ?? ""
        self.price = product.price ?? ""
        self.description = product.description ?? ""
        self.loadImageData = loadImageData
        self.image = Observable(nil, performOnMain: performOnMain)
    }
}

extension ProductsListItemViewModel {
    func loadImage() {
        loadImageData { data in
            image.value = data
        }
    }
}
