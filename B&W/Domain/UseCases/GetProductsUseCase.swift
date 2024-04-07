import Foundation

protocol GetProductsUseCase {
    // I prefer directly use `ProductQuery` instead of one level extra abstraction, `GetProductsUseCaseRequestValue`.
    // And the names of this function/param should be more "business", `execute` and `requestValue` are a bit technical,
    // because a use case embodies business logic/rules.
    // Maybe use `getProducts` instead of `execute`,
    // and `refinement`(the reason of choosing refinement is stated in `ProductQuery`) for "requestValue".
    func execute(requestValue: GetProductsUseCaseRequestValue,
                 completion: @escaping (Result<Products, Error>) -> Void) -> Cancellable?
}

final class DefaultGetProductsUseCase: GetProductsUseCase {
    private let productsRepository: ProductsRepository

    init(productsRepository: ProductsRepository) {
        self.productsRepository = productsRepository
    }

    func execute(requestValue: GetProductsUseCaseRequestValue,
                 completion: @escaping (Result<Products, Error>) -> Void) -> Cancellable? {
        return productsRepository.fetchProductsList(query: requestValue.query,
                                                    completion: { result in
            completion(result)
        })
    }
}

struct GetProductsUseCaseRequestValue {
    let query: ProductQuery
}
