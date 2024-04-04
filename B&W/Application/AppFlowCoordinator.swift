import UIKit

final class AppFlowCoordinator {
    private let tabBarController: UITabBarController
    private let navigationController: UINavigationController
    private let appDependencies: AppDependenciesContainer

    init(tabBarController: UITabBarController,
         navigationController: UINavigationController,
         appDependencies: AppDependenciesContainer) {
        self.tabBarController = tabBarController
        self.navigationController = navigationController
        self.appDependencies = appDependencies
    }

    func start() {
        let productsDependencies = appDependencies.makeProductsDependenciesContainer()
        let flow = productsDependencies.makeGetProductsFlowCoordinator(
            tabBarController: tabBarController,
            navigationController: navigationController
        )
        flow.start()
    }
}

final class AppDependenciesContainer {
    private let baseURL = URL(string: "https://my-json-server.typicode.com/daliad007/iOS-tech-test/")!
    private lazy var config: RequestConfig = ApiRequestConfig(baseURL: baseURL)
    
    private lazy var apiDataTransferService: DataTransferService = {
        let apiDataNetwork = DefaultNetworkService()
        return DefaultDataTransferService(with: apiDataNetwork)
    }()

    func makeProductsDependenciesContainer() -> ProductsDependenciesContainer {
        return ProductsDependenciesContainer(config: config, dataTransferService: apiDataTransferService)
    }
}
