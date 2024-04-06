import Foundation
import UIKit

// Rename from DependencyContainer to ProductsDependenciesContainer, a more explicit name.
final class ProductsDependenciesContainer {
    
    // Remove Dependencies struct, an extra level abstraction, since only a few of dependencies is needed at the moment.
    private let config: RequestConfig
    private let dataTransferService: DataTransferService
    private let loadImageDataUseCase: LoadImageDataUseCase
    
    init(config: RequestConfig, dataTransferService: DataTransferService, loadImageDataUseCase: LoadImageDataUseCase) {
        self.config = config
        self.dataTransferService = dataTransferService
        self.loadImageDataUseCase = loadImageDataUseCase
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
    
    private func makeProductsListItemViewModel(product: Product) -> ProductsListItemViewModel {
        return ProductsListItemViewModel(product: product, loadImageDataUseCase: loadImageDataUseCase)
    }

    private func makeProductDetailsViewModel(product: Product) -> ProductDetailsViewModel {
        return DefaultProductDetailsViewModel(product: product, loadImageDataUseCase: loadImageDataUseCase)
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
        let viewModel = makeProductsListViewModel(actions: actions)
        let listVC = ProductsListViewController.create(with: viewModel)
        listVC.didCellForRow = { [weak self] tableView, product in
            guard let self else { return nil }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: ProductListItemCell.reuseIdentifier) as? ProductListItemCell
            cell?.fill(with: makeProductsListItemViewModel(product: product))
            return cell
        }
        
        return listVC
    }

    func makeProductDetailsViewController(product: Product) -> ProductDetailsViewController {
        return ProductDetailsViewController.create(with: makeProductDetailsViewModel(product: product))
    }
}
