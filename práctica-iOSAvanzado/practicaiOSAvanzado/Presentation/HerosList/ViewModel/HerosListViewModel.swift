import Foundation
import UIKit.UIImage
import MapKit.MKUserLocation

protocol HerosListViewModelProtocol{
    func viewReady()
    func cellDidSelect(indexPath: Int)
    func annotationDidSelect(annotationView: MKAnnotationView)
    func getCellHeroData(index:Int) -> CellHeroData
    var getCellHeroesDataCount: Int {get}
    var getLoginViewModel:LoginViewModel {get}
}

final class HerosListViewModel{
    weak var viewController:HerosListViewControllerDelegate? = nil
    private var cellHeroesData:CellHeroesData? = nil
    private let dragonBallZNetwork:DragonBallZNetworkProtocol
    private let keychain:KeychainProtocol
    private let dataBase:DataBaseProtocol
    private lazy var loginViewModel: LoginViewModel = {
        LoginViewModel(
                    dragonBallZNetwork: dragonBallZNetwork,
                    keychain: keychain,
                    dataBase: dataBase
                )
    }()
    
    init(dragonBallZNetwork: DragonBallZNetworkProtocol, keychain: KeychainProtocol, dataBase: DataBaseProtocol) {
        self.dragonBallZNetwork = dragonBallZNetwork
        self.keychain = keychain
        self.dataBase = dataBase
    }
    
    func getImageFrom(url:URL,completion: @escaping (UIImage)->Void){
        let task = URLSession.shared.dataTask(with: URLRequest(url:url)) { (data, response, error) in
                        defer{
                            if let data, let image = UIImage(data: data) {
                                completion(image)
                            }else{
                                completion(UIImage())
                            }
                        }
                        guard error == nil else {
                            print("Error: \(String(describing: error))")
                            return
                        }
                        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                            print("Response Error: \(String(describing: response))")
                            return
                        }
                    }
        task.resume()
    }
    
    func getHeroLocationsFromApi(heroId:String,completion: @escaping(HeroLocations)->Void){
        self.dragonBallZNetwork.getHeroLocations(heroId: heroId) { data, error in
            defer{
                completion(data)
            }
            guard error == nil else {
                if let error {
                    print("Error: \(error.localizedDescription)")
                    debugPrint("Debug Info: \(error)")
                }
                return
            }
        }
    }
    
    func getHerosFromApi(completion: @escaping (Heros)->Void){
        self.dragonBallZNetwork.getHeroesList { data, error in
            defer{
                completion(data)
            }
            guard error == nil else {
                if let error {
                    print("Error: \(error.localizedDescription)")
                    debugPrint("Debug Info: \(error)")
                }
                return
            }
        }
    }
    
    func goWithApis() {
        DispatchQueue.global(qos: .default).async {
            var herosAnnotations: HerosAnnotations = []
            self.cellHeroesData = []
            
            self.getHerosFromApi { heros in
                let group = DispatchGroup()
                heros.forEach { hero in
                    group.enter()
                    self.getImageFrom(url: hero.photo) { image in
                        self.cellHeroesData?.append(CellHeroData(name: hero.name, description: hero.description, image: image))
                        
                        self.getHeroLocationsFromApi(heroId: hero.id) { heroLocations in
                            heroLocations.forEach{ heroLocation in
                                herosAnnotations.append(HeroAnnotation(title: hero.name, subtitle: hero.description, coordinate: CLLocationCoordinate2D(latitude: Double(heroLocation.latitud) ?? 0, longitude: Double(heroLocation.longitud) ?? 0), image: image))
                            }
                            group.leave()
                        }
                    }
                }
                
                group.notify(queue: .main) {
                    //actualizamos la vista
                    self.viewController?.updateTable()
                    self.viewController?.addAnnotationsToMapView(herosAnnotations: herosAnnotations)
                    
                    //guardamos los datos de los heroes y las annotations en el contexto de la base de datos y luego confirmamos el guardado de los datos que están en el contexto
                    self.dataBase.saveCellHeroesDataToContext(cellHeroesData: self.cellHeroesData ?? [CellHeroData(name: "", description: "", image: UIImage())])
                    self.dataBase.saveHerosAnnotationsToContext(herosAnnotations: herosAnnotations)
                    self.dataBase.saveContext()
                }
            }
        }
    }


    func goWithCoreData(cellHeroesData: CellHeroesData,herosAnnotations: HerosAnnotations){
        self.cellHeroesData = cellHeroesData
        
        viewController?.updateTable()
        viewController?.addAnnotationsToMapView(herosAnnotations: herosAnnotations)
        
        //eliminamos los datos del contexto para que en la próxima apertura de la aplicación entre por el llamado de las apis y vuelva a guardar los datos a la base de datos
        //dataBase.deleteAllCellHeroesData()
        //dataBase.saveContext()
    }
}

extension HerosListViewModel:HerosListViewModelProtocol{
    func viewReady(){
        //si directamente no hay token quiere decir que el usuario no se logeo y lo mandamos a la página de logeo
        if keychain.getToken() != nil{
            //si heros es igual a nil,es decir, si el usuario cerro y volvio a abrir la aplicación y no que regresó (pop) a la vista, verificamos si hay datos en el CoreData y tomamos los datos de ahí, sino llamamos a las apis y desde ellas guardamos luego los datos en el CoreData
            if (self.cellHeroesData == nil){
                if let cellHeroesData = dataBase.getAllCellHeroesData(), !cellHeroesData.isEmpty,
                   let herosAnnotations = dataBase.getAllHerosAnnotations(), !herosAnnotations.isEmpty{
                    goWithCoreData(cellHeroesData: cellHeroesData, herosAnnotations: herosAnnotations)
                }
                else{
                    goWithApis()
                }
            }
        }
        else{
            viewController?.navigateToLogin()
        }
    }
    func cellDidSelect(indexPath:Int){
        viewController?.navigateToHeroDetail(cellHeroData: self.getCellHeroData(index: indexPath))
    }
    func annotationDidSelect(annotationView: MKAnnotationView){
        viewController?.navigateToHeroDetail(cellHeroData: CellHeroData(name: (annotationView.annotation?.title ?? "") ?? "", description: (annotationView.annotation?.subtitle ?? "") ?? "", image: annotationView.image ?? UIImage()))
    }
    func getCellHeroData(index:Int) -> CellHeroData{
        self.cellHeroesData?[index] ?? CellHeroData(name: "", description: "", image: UIImage())
    }
    var getCellHeroesDataCount: Int{
        self.cellHeroesData?.count ?? 0
    }
    var getLoginViewModel: LoginViewModel{
        loginViewModel
    }
}
