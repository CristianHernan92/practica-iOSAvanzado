import Foundation

protocol LoginViewModelProtocol{
    func onLoginButtonClicked(email:String,password:String)
}

final class LoginViewModel{
    weak var viewController:LoginViewControllerProtocol? = nil
    private let dragonBallZNetwork:DragonBallZNetwork
    
    init(dragonBallZNetwork: DragonBallZNetwork) {
        self.dragonBallZNetwork = dragonBallZNetwork
    }
    
    private func login(email:String,password:String,completion: @escaping ()-> Void){
        DispatchQueue.global(qos: .default).async {
            self.dragonBallZNetwork.login(email: email, password: password) { error in
                defer{
                    completion()
                }
                guard error == nil else{
                    fatalError(error!.localizedDescription)
                }
            }
        }
    }
    
    
}

extension LoginViewModel:LoginViewModelProtocol{
    func onLoginButtonClicked(email:String,password:String) {
        login(email: email, password: password) {
            self.viewController?.navitateToHeroListViewController()
        }
    }
}
