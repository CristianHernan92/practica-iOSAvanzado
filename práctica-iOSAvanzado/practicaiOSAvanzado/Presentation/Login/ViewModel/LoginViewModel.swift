import Foundation

protocol LoginViewModelProtocol{
    func onViewDidLoad()
    func onLoginButtonClicked(email:String?,password:String?)
    var getHerosListViewModel:HerosListViewModelProtocol{get}
}

final class LoginViewModel{
    weak var viewController:LoginViewControllerDelegate? = nil
    
    private let dragonBallZNetwork:DragonBallZNetworkProtocol
    private let keychain:KeychainProtocol
    private let dataBase:DataBaseProtocol
    private let herosListViewModel: HerosListViewModelProtocol
    
    init(dragonBallZNetwork: DragonBallZNetworkProtocol, keychain: KeychainProtocol, dataBase: DataBaseProtocol) {
        self.dragonBallZNetwork = dragonBallZNetwork
        self.keychain = keychain
        self.dataBase = dataBase
        herosListViewModel = HerosListViewModel(
            dragonBallZNetwork: dragonBallZNetwork,
            keychain: keychain,
            dataBase: dataBase
        )
    }
    
    private func login(email:String,password:String,completion: @escaping ()-> Void){
        DispatchQueue.global(qos: .default).async {
            self.dragonBallZNetwork.login(email: email, password: password) { error in
                guard error == nil else{
                    if let error {print(error.localizedDescription)}
                    return
                }
                completion()
            }
        }
    }
    
    
}

extension LoginViewModel:LoginViewModelProtocol{
    func onViewDidLoad() {
        viewController?.hideNavigationBar()
    }
    func onLoginButtonClicked(email:String?,password:String?) {
        if let email, let password {
            login(email: email, password: password) {
                self.viewController?.navitateToHeroList()
            }
        }
    }
    var getHerosListViewModel: HerosListViewModelProtocol{
        herosListViewModel
    }
}
