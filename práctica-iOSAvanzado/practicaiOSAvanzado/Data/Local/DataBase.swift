import UIKit
import CoreData
import MapKit.MKUserLocation

protocol DataBaseProtocol{
    func saveCellHeroesDataToContext(cellHeroesData: CellHeroesData)
    func getAllCellHeroesData() -> CellHeroesData?
    func deleteAllCellHeroesData()
    func saveHerosAnnotationsToContext(herosAnnotations: HerosAnnotations)
    func getAllHerosAnnotations() -> HerosAnnotations?
    func deleteAllHerosAnnotations()
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
    
    //cell heroes data
    
    func saveCellHeroesDataToContext(cellHeroesData: CellHeroesData) {
        guard let context,let entity = NSEntityDescription.entity(forEntityName: "CellHeroDataEntity", in: context)
        else {return}
        cellHeroesData.forEach{ cellHeroData in
            let cellHeroDataEntity = NSManagedObject(entity: entity, insertInto: context)
            cellHeroDataEntity.setValue(cellHeroData.name, forKey: "name")
            cellHeroDataEntity.setValue(cellHeroData.description, forKey: "detail")
            cellHeroDataEntity.setValue(cellHeroData.image, forKey: "image")
        }
    }
    
    func getAllCellHeroesData() -> CellHeroesData? {
        let fetch = NSFetchRequest<CellHeroDataEntity>(entityName: "CellHeroDataEntity")
        guard let context, let fetchResult = try? context.fetch(fetch)
        else{ return nil }
        
        var cellHeroesData:CellHeroesData=[]
        fetchResult.forEach{ cellheroDataEntity in
            cellHeroesData.append(CellHeroData(
                name: cellheroDataEntity.name,
                description: cellheroDataEntity.detail,
                image: cellheroDataEntity.image)
            )
        }
        return cellHeroesData
    }
    
    func deleteAllCellHeroesData(){
        let fetch = NSFetchRequest<CellHeroDataEntity>(entityName: "CellHeroDataEntity")
        guard let context,let fetchResult = try? context.fetch(fetch)
        else {return}
        
        fetchResult.forEach{ cellheroDataEntity in
            context.delete(cellheroDataEntity)
        }
    }
    
    //heros annotations
    
    func saveHerosAnnotationsToContext(herosAnnotations: HerosAnnotations) {
        guard let context,let entity = NSEntityDescription.entity(forEntityName: "HeroAnnotationEntity", in: context)
        else {return}
        herosAnnotations.forEach{ heroAnnotation in
            let heroAnnotationEntity = NSManagedObject(entity: entity, insertInto: context)
            heroAnnotationEntity.setValue(heroAnnotation.title, forKey: "title")
            heroAnnotationEntity.setValue(heroAnnotation.subtitle, forKey: "subtitle")
            heroAnnotationEntity.setValue(heroAnnotation.image, forKey: "image")
            heroAnnotationEntity.setValue(heroAnnotation.coordinate.longitude, forKey: "longitud")
            heroAnnotationEntity.setValue(heroAnnotation.coordinate.latitude, forKey: "latitud")
        }
    }
    
    func getAllHerosAnnotations() -> HerosAnnotations? {
        let fetch = NSFetchRequest<HeroAnnotationEntity>(entityName: "HeroAnnotationEntity")
        guard let context, let fetchResult = try? context.fetch(fetch)
        else{ return nil }
        
        var herosAnnotations:HerosAnnotations=[]
        fetchResult.forEach{ heroAnnotationEntity in
            herosAnnotations.append(HeroAnnotation(title: heroAnnotationEntity.title, subtitle: heroAnnotationEntity.subtitle, coordinate: CLLocationCoordinate2D(latitude: heroAnnotationEntity.latitud, longitude: heroAnnotationEntity.longitud), image: heroAnnotationEntity.image))
        }
        return herosAnnotations
    }
    
    func deleteAllHerosAnnotations(){
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
