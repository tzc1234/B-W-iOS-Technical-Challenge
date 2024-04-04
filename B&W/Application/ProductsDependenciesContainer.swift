import Foundation
import UIKit

// Rename from DependencyContainer to ProductsDependenciesContainer, a more explicit name.
final class ProductsDependenciesContainer {
    
    // Remove Dependencies struct, an extra level abstraction, since only one dependency is needed at the moment.
    private let dataTransferService: DataTransferService
    
    init(dataTransferService: DataTransferService) {
        self.dataTransferService = dataTransferService
    }
    
    // MARK: - Flow Coordinators
    
    func makeGetProductsFlowCoordinator(tabBarController: UITabBarController, navigationController: UINavigationController) -> GetProductsFlowCoordinator {
        return GetProductsFlowCoordinator(tabBarController: tabBarController, navigationController: navigationController,
                                          dependencies: self)
    }

    // MARK: - View Models

    private func makeProductsListViewModel(actions: ProductsListViewModelActions) -> ProductsListViewModel {
        return DefaultProductsListViewModel(useCase: makeGetProductsUseCase(), actions: actions)
    }

    private func makeProductDetailsViewModel(product: Product) -> ProductDetailsViewModel {
        return DefaultProductDetailsViewModel(product: product)
    }
    
    // MARK: - Use Cases

    private func makeGetProductsUseCase() -> GetProductsUseCase {
        return DefaultGetProductsUseCase(productsRepository: makeProductsRepository())
    }

    // MARK: - Repositories

    private func makeProductsRepository() -> ProductsRepository {
        return DefaultProductsRepository(dataTransferService: dataTransferService)
    }
}

extension ProductsDependenciesContainer: GetProductsFlowCoordinatorDependencies {
    // MARK: - Controllers
    
    func makeProductsListViewController(actions: ProductsListViewModelActions) -> ProductsListViewController {
        return ProductsListViewController.create(with: makeProductsListViewModel(actions: actions))
    }

    func makeProductDetailsViewController(product: Product) -> ProductDetailsViewController {
        return ProductDetailsViewController.create(with: makeProductDetailsViewModel(product: product))
    }
}
