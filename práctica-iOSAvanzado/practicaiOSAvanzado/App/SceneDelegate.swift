import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        //keychain, network, coredata and the viewmodel for heroslistviewcontroller
        let keychain:KeychainProtocol = Keychain()
        let dataBase:DataBaseProtocol = DataBase(context: (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext)
        let dragonBallZNetwork: DragonBallZNetworkProtocol = DragonBallZNetwork(keychain: keychain)
        let herosListViewModel = HerosListViewModel(
            dragonBallZNetwork: dragonBallZNetwork,
            keychain: keychain,
            dataBase: dataBase
        )
        
        let storyboard = UIStoryboard(name: "HerosList", bundle: nil)
        let rootViewController = storyboard.instantiateViewController(withIdentifier: "HerosListStoryboard") as? HerosListViewController
        herosListViewModel.viewController = rootViewController
        rootViewController?.viewModel = herosListViewModel
        
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = UINavigationController(rootViewController: rootViewController ?? UIViewController())
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
    }


}

