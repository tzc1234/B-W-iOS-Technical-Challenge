import Foundation

protocol ProductsRepository {
    func fetchProductsList(refinement: Refinement,
                           completion: @escaping (Result<Products, Error>) -> Void) -> Cancellable?
}
