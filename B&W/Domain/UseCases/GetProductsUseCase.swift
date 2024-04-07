import Foundation

protocol GetProductsUseCase {
    // I prefer directly use `ProductQuery` instead of one level extra abstraction, `GetProductsUseCaseRequestValue`.
    // And the names of this function/param should be more "business", `execute` and `requestValue` are a bit technical.
    // Because a use case embodies business logic/rules, maybe use `getProducts` instead of `execute`,
    // and `refinement`(the reason of choosing refinement is stated in `Refinement`) for "requestValue".
    func getProducts(with refinement: Refinement,
                     completion: @escaping (Result<Products, Error>) -> Void) -> Cancellable?
}

final class DefaultGetProductsUseCase: GetProductsUseCase {
    private let productsRepository: ProductsRepository

    init(productsRepository: ProductsRepository) {
        self.productsRepository = productsRepository
    }

    func getProducts(with refinement: Refinement,
                     completion: @escaping (Result<Products, Error>) -> Void) -> Cancellable? {
        return productsRepository.fetchProductsList(refinement: refinement) { result in
            completion(result)
        }
    }
}
