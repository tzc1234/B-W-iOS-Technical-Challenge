import Foundation
import UIKit

final class DependencyContainer {

    struct Dependencies {
        let apiDataTransferService: DataTransferService
    }

    private let dependencies: Dependencies

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    // MARK: - Use Cases

    func makeGetProductsUseCase() -> GetProductsUseCase {
        return DefaultGetProductsUseCase(productsRepository: makeProductsRepository())
    }

    // MARK: - Repositories

    func makeProductsRepository() -> ProductsRepository {
        return DefaultProductsRepository(dataTransferService: dependencies.apiDataTransferService)
    }

    // MARK: - Controllers

    func makeProductsListViewController(actions: ProductsListViewModelActions) -> ProductsListViewController {
        return ProductsListViewController.create(with: makeProductsListViewModel(actions: actions))
    }

    func makeProductDetailsViewController(product: Product) -> ProductDetailsViewController {

        return ProductDetailsViewController.create(with: makeProductDetailsViewModel(product: product))
    }

    // MARK: - View Models

    func makeProductsListViewModel(actions: ProductsListViewModelActions) -> ProductsListViewModel {
        return DefaultProductsListViewModel(useCase: makeGetProductsUseCase(),
                                          actions: actions)
    }

    func makeProductDetailsViewModel(product: Product) -> ProductDetailsViewModel {
        return DefaultProductDetailsViewModel(product: product)
    }

    // MARK: - Flow Coordinators
    func makeGetProductsFlowCoordinator(tabBarController: UITabBarController, navigationController: UINavigationController) -> GetProductsFlowCoordinator {
        return GetProductsFlowCoordinator(tabBarController: tabBarController, navigationController: navigationController,
                                          dependencies: self)
    }
}

extension DependencyContainer: GetProductsFlowCoordinatorDependencies {}
