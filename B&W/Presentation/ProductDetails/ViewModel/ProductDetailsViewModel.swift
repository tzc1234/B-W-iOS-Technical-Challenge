import Foundation

protocol ProductDetailsViewModelInput {
    func updateImage()
    func cancelImageLoading()
}

protocol ProductDetailsViewModelOutput {
    var name: String { get }
    var image: Observable<Data?> { get }
    var description: String { get }
    var price: String { get }
}

typealias ProductDetailsViewModel = ProductDetailsViewModelInput & ProductDetailsViewModelOutput

final class DefaultProductDetailsViewModel: ProductDetailsViewModel {
    private let imagePath: String?
    private var imageDataLoading: Cancellable?

    let name: String
    let image: Observable<Data?> = Observable(nil)
    let description: String
    let price: String
    private let imageDataLoader: ImageDataLoader

    init(product: Product, imageDataLoader: ImageDataLoader) {
        self.name = product.name ?? ""
        self.description = product.description ?? ""
        self.imagePath = product.imagePath
        self.price = product.price ?? ""
        self.imageDataLoader = imageDataLoader
    }
}

extension DefaultProductDetailsViewModel {
    func updateImage() {
        guard let imagePath, let url = URL(string: imagePath) else { return }
        
        // Use ImageDataLoader for image loading on background queue,
        // instead of directly using Data(contentsOf:)
        imageDataLoading = imageDataLoader.load(for: url) { [weak self] result in
            switch result {
            case let .success(data):
                self?.image.value = data
            case .failure:
                break
            }
        }
    }
    
    // Add cancel image data loading for view.
    func cancelImageLoading() {
        imageDataLoading?.cancel()
    }
}
