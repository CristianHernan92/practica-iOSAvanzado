import Foundation
import UIKit.UIImage
import MapKit.MKUserLocation

enum ViewState{
    case ready
}

protocol HerosListViewModelProtocol{
    func on(_ state:ViewState)
    func getHeroData(index:Int)->(heroName:String,heroDescription:String,heroImage:UIImage)
    var getHerosCount: Int {get}
    var getLoginViewModel:LoginViewModel {get}
}

final class HerosListViewModel{
    weak var viewController:HerosListViewControllerDelegate? = nil
    private var herosData:[(heroName:String,heroDescription:String,heroImage:UIImage)]? = nil
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
    
    func saveHeroInCoreData(name:String,detail:String,image: UIImage){
        self.dataBase.saveHero(name: name, detail: detail, image: image)
    }
    
    func saveHeroAnnotationInCoreData(title:String,subtitle:String,image:UIImage,latitud:Double,longitud:Double){
        self.dataBase.saveHeroAnnotation(title: title, subtitle: subtitle, image: image, latitud: latitud, longitud: longitud)
    }
    
    func createHeroAnnotation(title:String,subtitle:String, coordinate: CLLocationCoordinate2D,image: UIImage)->HeroAnnotation{
        let heroAnnotation = HeroAnnotation(
            title: title,
            subtitle: subtitle,
            coordinate: coordinate,
            image: image
        )
        return heroAnnotation
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
            self.herosData=[]
            self.getHerosFromApi { heros in
                let group = DispatchGroup()
                heros.forEach { hero in
                    group.enter()
                    self.getImageFrom(url: hero.photo) { image in
                        self.herosData?.append((heroName: hero.name, heroDescription: hero.description, heroImage: image))
                        self.saveHeroInCoreData(name: hero.name, detail: hero.description, image: image)
                        
                        self.getHeroLocationsFromApi(heroId: hero.id) { heroLocations in
                            heroLocations.forEach { heroLocation in
                                self.viewController?.addAnnotationToMapView(heroAnnotation: HeroAnnotation(title: hero.name, subtitle: hero.description, coordinate: CLLocationCoordinate2D(latitude: Double(heroLocation.latitud) ?? 0, longitude: Double(heroLocation.longitud) ?? 0), image: image))
                                self.saveHeroAnnotationInCoreData(title: hero.name, subtitle: hero.description, image: image, latitud: Double(heroLocation.latitud) ?? 0, longitud: Double(heroLocation.longitud) ?? 0)
                            }
                            group.leave()
                        }
                    }
                }
                group.notify(queue: .main) {
                    //cuando termina todo confirmamos el guardado en la base de datos y actualizamos la tabla de la vista
                    self.viewController?.updateTable()
                    self.dataBase.saveContext()
                }
            }
        }
    }


    func goWithCoreData(herosEntities: [HeroEntity],heroAnnotationsEntities: [HeroAnnotationEntity]){
        self.herosData=[]
        
        herosEntities.forEach{ HeroEntity in
            self.herosData?.append((heroName: HeroEntity.name, heroDescription: HeroEntity.detail, heroImage: HeroEntity.image))
        }
        
        heroAnnotationsEntities.forEach{ heroAnnotationEntity in
            self.viewController?.addAnnotationToMapView(
                heroAnnotation: HeroAnnotation(
                    title: heroAnnotationEntity.title,
                    subtitle: heroAnnotationEntity.subtitle,
                    coordinate: CLLocationCoordinate2D(latitude: heroAnnotationEntity.latitud, longitude: heroAnnotationEntity.longitud),
                    image: heroAnnotationEntity.image)
            )
        }
        
        viewController?.updateTable()
        
        //eliminamos los datos del contexto para que en la próxima apertura de la aplicación entre por el llamado de las apis para que vuelva a cargar los datos al core data
        dataBase.deleteAllHerosEntities()
        dataBase.saveContext()
    }
    
    func viewReady() {
        //si directamente no hay token quiere decir que el usuario no se logeo y lo mandamos a la página de logeo
        if keychain.getToken() != nil{
            //si heros es igual a nil,es decir, si el usuario cerro y volvio a abrir la aplicación y no que regresó (pop) a la vista, verificamos si hay datos en el CoreData y tomamos los datos de ahí, sino llamamos a las apis y desde ellas guardamos luego los datos en el CoreData
            if (self.herosData == nil){
                if let herosEntities = dataBase.getAllHerosEntities(), !herosEntities.isEmpty,
                   let heroAnnotationsEntities = dataBase.getAllHerosAnnotationsEntities(), !heroAnnotationsEntities.isEmpty{
                    goWithCoreData(herosEntities: herosEntities, heroAnnotationsEntities: heroAnnotationsEntities)
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
}

extension HerosListViewModel:HerosListViewModelProtocol{
    func on(_ state: ViewState) {
        switch state{
            case .ready: viewReady()
        }
    }
    func getHeroData(index:Int)->(heroName:String,heroDescription:String,heroImage:UIImage){
        self.herosData?[index] ?? (heroName:"",heroDescription:"",heroImage:UIImage())
    }
    var getHerosCount: Int{
        self.herosData?.count ?? 0
    }
    var getLoginViewModel: LoginViewModel{
        loginViewModel
    }
}
