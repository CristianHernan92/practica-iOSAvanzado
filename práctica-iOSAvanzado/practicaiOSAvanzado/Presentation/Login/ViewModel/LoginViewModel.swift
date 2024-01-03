import Foundation

protocol LoginViewModelProtocol{
    func onLoginButtonClicked(email:String,password:String)
    var getHerosListViewModel:HerosListViewModel{get}
}

final class LoginViewModel{
    weak var viewController:LoginViewControllerDelegate? = nil
    
    private let dragonBallZNetwork:DragonBallZNetwork
    private let keychain:Keychain
    private let dataBase:DataBase
    private let herosListViewModel: HerosListViewModel
    
    init(dragonBallZNetwork: DragonBallZNetwork, keychain: Keychain, dataBase: DataBase) {
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
    func onLoginButtonClicked(email:String,password:String) {
        login(email: email, password: password) {
            self.viewController?.navitateToHeroList()
        }
    }
    var getHerosListViewModel: HerosListViewModel{
        herosListViewModel
    }
}
