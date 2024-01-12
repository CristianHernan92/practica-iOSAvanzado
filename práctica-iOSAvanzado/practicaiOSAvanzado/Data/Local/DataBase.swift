import UIKit
import CoreData
import MapKit.MKUserLocation

protocol DataBaseProtocol{
    func saveHero(name:String,detail:String,image:UIImage)
    func getAllHerosEntities() -> [HeroEntity]?
    func deleteAllHerosEntities()
    func saveHeroAnnotation(title:String,subtitle:String,image:UIImage,latitud:Double,longitud:Double)
    func getAllHerosAnnotationsEntities() -> [HeroAnnotationEntity]?
    func deleteAllHerosAnnotationsEntities()
    func saveContext()
}

final class DataBase {
    private weak var mainContext: NSManagedObjectContext?
    init(context: NSManagedObjectContext?) {
        self.mainContext = context
    }
    private var context: NSManagedObjectContext? {
        return mainContext
    }
}


extension DataBase:DataBaseProtocol{
    
    //hero
    
    func saveHero(name:String,detail:String,image:UIImage) {
        guard let context,let entity = NSEntityDescription.entity(forEntityName: "HeroEntity", in: context)
        else {return}
        let heroEntity = NSManagedObject(entity: entity, insertInto: context)
        heroEntity.setValue(name, forKey: "name")
        heroEntity.setValue(detail, forKey: "detail")
        heroEntity.setValue(image, forKey: "image")
    }
    
    func getAllHerosEntities() -> [HeroEntity]? {
        let fetch = NSFetchRequest<HeroEntity>(entityName: "HeroEntity")
        guard let context, let fetchResult = try? context.fetch(fetch)
        else{ return nil }
        
        var herosEntities:[HeroEntity]=[]
        fetchResult.forEach{ heroEntity in
            herosEntities.append(heroEntity)
        }
        return herosEntities
    }
    
    func deleteAllHerosEntities(){
        let fetch = NSFetchRequest<HeroEntity>(entityName: "HeroEntity")
        guard let context,let fetchResult = try? context.fetch(fetch)
        else {return}
        
        fetchResult.forEach{ heroEntity in
            context.delete(heroEntity)
        }
    }
    
    //hero annotation entity
    
    func saveHeroAnnotation(title:String,subtitle:String,image:UIImage,latitud:Double,longitud:Double) {
        guard let context,let entity = NSEntityDescription.entity(forEntityName: "HeroAnnotationEntity", in: context)
        else {return}
        let heroAnnotationEntity = NSManagedObject(entity: entity, insertInto: context)
        heroAnnotationEntity.setValue(title, forKey: "title")
        heroAnnotationEntity.setValue(subtitle, forKey: "subtitle")
        heroAnnotationEntity.setValue(image, forKey: "image")
        heroAnnotationEntity.setValue(longitud, forKey: "longitud")
        heroAnnotationEntity.setValue(latitud, forKey: "latitud")
    }
    
    func getAllHerosAnnotationsEntities() -> [HeroAnnotationEntity]? {
        let fetch = NSFetchRequest<HeroAnnotationEntity>(entityName: "HeroAnnotationEntity")
        guard let context, let fetchResult = try? context.fetch(fetch)
        else{ return nil }
        
        var herosAnnotationsEntities:[HeroAnnotationEntity]=[]
        fetchResult.forEach{ heroAnnotationEntity in
            herosAnnotationsEntities.append(heroAnnotationEntity)
        }
        return herosAnnotationsEntities
    }
    
    func deleteAllHerosAnnotationsEntities(){
        let fetch = NSFetchRequest<HeroAnnotationEntity>(entityName: "HeroAnnotationEntity")
        guard let context,let fetchResult = try? context.fetch(fetch)
        else {return}
        
        fetchResult.forEach{ heroAnnotationEntity in
            context.delete(heroAnnotationEntity)
        }
    }
    
    func saveContext() {
        guard let context else {return}
        do {
            try context.save()
        } catch let error as NSError {
            print("Error al guardar en CoreData: \(error.localizedDescription)")
            print("Detalles del error: \(error.userInfo)")
        }
        
    }
    
}
