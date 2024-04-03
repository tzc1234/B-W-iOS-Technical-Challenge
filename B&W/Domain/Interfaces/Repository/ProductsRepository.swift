import Foundation

protocol ProductsRepository {
    func fetchProductsList(query: ProductQuery,
                           completion: @escaping (Result<Products, Error>) -> Void) -> Cancellable?
}
