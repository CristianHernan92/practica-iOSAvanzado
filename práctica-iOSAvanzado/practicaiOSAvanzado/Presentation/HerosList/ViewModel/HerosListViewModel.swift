import Foundation

enum ViewState{
    case ready
}

protocol HerosListViewModelProtocol{
    func on(_ state:ViewState)
    func getHero(index:Int)->Hero
    var getHerosCount: Int {get}
    var getLoginViewModel:LoginViewModel {get}
}

final class HerosListViewModel{
    weak var viewController:HerosListViewControllerDelegate? = nil
    private var heros:Heros = []
    private let dragonBallZNetwork:DragonBallZNetwork
    private let keychain:Keychain
    private let dataBase:DataBase
    private lazy var loginViewModel: LoginViewModel = {
        LoginViewModel(
                    dragonBallZNetwork: dragonBallZNetwork,
                    keychain: keychain,
                    dataBase: dataBase
                )
    }()
    
    init(dragonBallZNetwork: DragonBallZNetwork, keychain: Keychain, dataBase: DataBase) {
        self.dragonBallZNetwork = dragonBallZNetwork
        self.keychain = keychain
        self.dataBase = dataBase
    }
    
    func viewReady() {
        if keychain.getToken() != nil{
            if self.heros == []{
                if let heros = dataBase.getHeros(), !heros.isEmpty{
                    self.heros = heros
                    viewController?.updateTable()
                    dataBase.deleteHeros()
                }else{
                    DispatchQueue.global(qos: .default).async {
                        self.dragonBallZNetwork.getHeroesList { heros, error in
                            guard error == nil else{
                                if let error {print(error.localizedDescription)}
                                return
                            }
                            self.heros = heros
                            self.viewController?.updateTable()
                        }
                    }
                }
            }
        }
        else{
            viewController?.navigateToLogin()
        }
    }
}

extension HerosListViewModel:HerosListViewModelProtocol{
    func on(_ state: ViewState) {
        switch state{
            case .ready: viewReady()
        }
    }
    func getHero(index:Int)->Hero{
        heros[index]
    }
    var getHerosCount: Int{
        heros.count
    }
    var getLoginViewModel: LoginViewModel{
        loginViewModel
    }
}
