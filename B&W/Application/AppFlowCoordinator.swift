import UIKit

final class AppFlowCoordinator {

    var tabBarController: UITabBarController
    var navigationController: UINavigationController
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
        let flow = productsDependencies.makeGetProductsFlowCoordinator(tabBarController: tabBarController, navigationController: navigationController)
        flow.start()
    }
}

final class AppDependenciesContainer {

    lazy var apiDataTransferService: DataTransferService = {
        let config = ApiRequestConfig(baseURL: URL(string: "https://my-json-server.typicode.com/daliad007/iOS-tech-test/")!)

        let apiDataNetwork = DefaultNetworkService(config: config)
        return DefaultDataTransferService(with: apiDataNetwork)
    }()

    func makeProductsDependenciesContainer() -> DependencyContainer {
        let dependencies = DependencyContainer.Dependencies(apiDataTransferService: apiDataTransferService)
        return DependencyContainer(dependencies: dependencies)
    }
}
