import Foundation

protocol ProductDetailsViewModelInput {
    func updateImage()
}

protocol ProductDetailsViewModelOutput {
    var name: String { get }
    var image: Observable<Data?> { get }
    var description: String { get }
    var price: String { get }
}

protocol ProductDetailsViewModel: ProductDetailsViewModelInput, ProductDetailsViewModelOutput { }

final class DefaultProductDetailsViewModel: ProductDetailsViewModel {

    private let imagePath: String?

    let name: String
    let image: Observable<Data?> = Observable(nil)
    let description: String
    let price: String

    init(product: Product) {
        self.name = product.name ?? ""
        self.description = product.description ?? ""
        self.imagePath = product.imagePath
        self.price = product.price ?? ""
    }
}

extension DefaultProductDetailsViewModel {
    func updateImage() {
        guard let imagePath = imagePath else { return }

        let url = URL(string: imagePath)!

        // Fetch Image Data
        if let data = try? Data(contentsOf: url) {
            // Create Image and Update Image View
            self.image.value = data
        }
    }
}
