import Foundation

struct ProductsListItemViewModel {
    typealias LoadImageData = (@escaping (Data) -> Void) -> Void
    
    let image: Observable<Data?> = Observable(nil)
    
    let name: String
    let price: String
    let description: String
    
    // Holding a image Data callback closure injected from DefaultProductsListViewModel.
    private let loadImageData: LoadImageData
    
    init(product: Product, loadImageData: @escaping LoadImageData) {
        self.name = product.name ?? ""
        self.price = product.price ?? ""
        self.description = product.description ?? ""
        self.loadImageData = loadImageData
    }
}

extension ProductsListItemViewModel {
    func loadImage() {
        loadImageData { data in
            image.value = data
        }
    }
}
