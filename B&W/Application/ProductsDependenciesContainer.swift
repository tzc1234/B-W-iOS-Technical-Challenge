import Foundation
import UIKit

// Rename from DependencyContainer to ProductsDependenciesContainer, a more explicit name.
final class ProductsDependenciesContainer {
    
    // Remove Dependencies struct, an extra level abstraction, since only a few of dependencies is needed at the moment.
    private let config: RequestConfig
    private let dataTransferService: DataTransferService
    
    init(config: RequestConfig, dataTransferService: DataTransferService) {
        self.config = config
        self.dataTransferService = dataTransferService
    }
    
    // MARK: - Flow Coordinators
    
    func makeGetProductsFlowCoordinator(tabBarController: UITabBarController, 
                                        navigationController: UINavigationController) -> GetProductsFlowCoordinator {
        return GetProductsFlowCoordinator(
            tabBarController: tabBarController,
            navigationController: navigationController,
            dependencies: self
        )
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
        return DefaultProductsRepository(endpoints: makeProductsEndpoints(), dataTransferService: dataTransferService)
    }
    
    // MARK: - Endpoints
    
    private func makeProductsEndpoints() -> ProductsEndpoints {
        ProductsRepositoryEndpoints(config: config)
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
