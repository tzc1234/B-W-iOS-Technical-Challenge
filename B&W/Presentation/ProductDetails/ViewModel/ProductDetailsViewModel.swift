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
    private var imageDataLoading: Cancellable?

    let image: Observable<Data?> = Observable(nil)
    
    let name: String
    let description: String
    let price: String
    private let imagePath: URL?
    private let loadImageDataUseCase: LoadImageDataUseCase

    init(product: Product, loadImageDataUseCase: LoadImageDataUseCase) {
        self.name = product.name ?? ""
        self.description = product.description ?? ""
        self.price = product.price ?? ""
        self.imagePath = product.imagePath
        self.loadImageDataUseCase = loadImageDataUseCase
    }
}

extension DefaultProductDetailsViewModel {
    func updateImage() {
        guard let imagePath else { return }
        
        // Use LoadImageDataUseCase for image loading on background queue,
        // instead of directly using Data(contentsOf:)
        imageDataLoading = loadImageDataUseCase.load(for: imagePath) { [weak self] result in
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
