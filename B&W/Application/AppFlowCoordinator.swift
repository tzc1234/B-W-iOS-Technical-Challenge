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
    private lazy var config = ApiRequestConfig(baseURL: baseURL)
    
    private let networkService = DefaultNetworkService()
    private lazy var dispatchOnMainQueueNetworkService: NetworkService = DispatchOnMainQueueDecorator(decoratee: networkService)
    private lazy var dataTransferService = DefaultDataTransferService(with: dispatchOnMainQueueNetworkService)
    
    private lazy var imageDataRepository = DefaultImageDataRepository(
        service: dispatchOnMainQueueNetworkService,
        makeRequestable: FullPathEndpoint.init
    )
    private lazy var loadImageDataUseCase = DefaultLoadImageDataUseCase(repository: imageDataRepository)
    
    func makeProductsDependenciesContainer() -> ProductsDependenciesContainer {
        return ProductsDependenciesContainer(
            config: config,
            dataTransferService: dataTransferService,
            loadImageDataUseCase: loadImageDataUseCase
        )
    }
}
