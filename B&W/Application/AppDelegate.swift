import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    let appDIContainer = AppDependenciesContainer()
    var appFlowCoordinator: AppFlowCoordinator?
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        window = UIWindow(frame: UIScreen.main.bounds)

        let navigationController = UINavigationController()

        let tabBarController = UITabBarController()

        window?.rootViewController = tabBarController
        
        appFlowCoordinator = AppFlowCoordinator(tabBarController: tabBarController,
                                                navigationController: navigationController,
                                                appDependencies: appDIContainer)
        appFlowCoordinator?.start()

        window?.makeKeyAndVisible()

        return true
    }

}
