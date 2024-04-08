import Foundation

final class ProductsListItemViewModel {
    let image: Observable<Data?>
    
    let name: String
    let price: String
    let description: String
    private let imagePath: URL?
    private let loadImageDataUseCase: LoadImageDataUseCase
    
    init(product: Product, loadImageDataUseCase: LoadImageDataUseCase) {
        self.name = product.name ?? ""
        self.price = product.price ?? ""
        self.description = product.description ?? ""
        self.imagePath = product.imagePath
        self.loadImageDataUseCase = loadImageDataUseCase
        self.image = Observable(nil)
    }
}

extension ProductsListItemViewModel {
    func loadImage() {
        guard let imagePath else { return }
        
        _ = loadImageDataUseCase.load(for: imagePath) { [weak self] result in
            switch result {
            case let .success(data):
                self?.image.value = data
            case .failure:
                break
            }
        }
    }
}
