import XCTest
import CoreData
@testable import practicaiOSAvanzado

final class HerosListViewControllerTest : XCTestCase{
    
    //MARK: -INSTANCIA DE ...-
    var sut:HerosListViewController!
    
    var keychain:KeychainProtocol!
    var dragonBallZNetwork:DragonBallZNetworkProtocol!
    var database: DataBaseProtocol!
    var herosListViewModel:HerosListViewModel!
    
    
    //MARK: -SE EJECUTA ANTES DE CADA TEST (REINICIALIZACIÓN)-
    override func setUp() {
        super.setUp()
        
        //keychain,dragonBallZNetwork
        keychain = Keychain()
        dragonBallZNetwork = DragonBallZNetwork(keychain: keychain)
        
        //database
        let persistentContainer = NSPersistentContainer(name: "practicaiOSAvanzado")
        let persistentStoreDescription = NSPersistentStoreDescription()
        persistentStoreDescription.type = NSInMemoryStoreType
        persistentContainer.persistentStoreDescriptions = [persistentStoreDescription]
        persistentContainer.loadPersistentStores { (persistentStoreDescription, error) in
            if let error = error { fatalError("No se puede crear el almacén de datos en memoria: \(error)")}
        }
        database = DataBase(context: persistentContainer.viewContext)
        
        //herosListViewModel
        herosListViewModel = HerosListViewModel(dragonBallZNetwork: dragonBallZNetwork, keychain: keychain, dataBase: database)
        
        //herosListViewController
        sut = HerosListViewController()
        sut.viewModel = herosListViewModel
    }
    
    //MARK: -SE EJECUTA DESPUÉS DE CADA TEST (LIMPIEZA)-
    override func tearDown() {
        super.tearDown()
        sut = nil
        keychain.removeToken()
        keychain = nil
        dragonBallZNetwork = nil
        database = nil
        herosListViewModel = nil
    }
    
    //MARK: -TESTS-
    func test_tokenRemovedWhenClickInLogoutButton(){
        keychain.saveToken(token: "qwert1234")
        sut.viewModel?.logoutIconButonTouched()
        XCTAssertNil(keychain.getToken())
    }
    
    //...
}
