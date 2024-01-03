import UIKit
import CoreData

protocol DataBaseProtocol{
    func saveHeros(heros: Heros)
    func getHeros()->Heros?
}

final class DataBase{
    private var context:NSManagedObjectContext?
    init(){
        DispatchQueue.main.async {
            self.context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
        }
    }
}

extension DataBase:DataBaseProtocol{
    
    func saveHeros(heros: Heros) {
        guard let context,let entityHero = NSEntityDescription.entity(forEntityName: "Heroe", in: context)
        else {return}
        
        heros.forEach{ hero in
            let heroe = NSManagedObject(entity: entityHero, insertInto: context)
            heroe.setValue(hero.id, forKey: "id")
            heroe.setValue(hero.name, forKey: "name")
            heroe.setValue(hero.description, forKey: "heroDescription")
            heroe.setValue(hero.favorite, forKey: "favorite")
            heroe.setValue(hero.photo.absoluteString, forKey: "imageURL")
        }
        try? context.save()
    }
    
    func getHeros() -> Heros? {
        let heroFetch = NSFetchRequest<Heroe>(entityName: "Heroe")
        guard let context, let heroesResult = try? context.fetch(heroFetch)
        else{ return [] }
        
        var heroes:Heros=[]
        heroesResult.forEach{ heroe in
            heroes.append(Hero(
                id: heroe.id ?? "",
                name: heroe.name ?? "",
                description: heroe.heroDescription ?? "",
                photo: URL(string: heroe.imageURL ?? "")!,
                favorite: heroe.favorite))
        }
        return heroes
    }
    
    func deleteHeros(){
        let heroFetch = NSFetchRequest<Heroe>(entityName: "Heroe")
        guard let context,let heroesResult = try? context.fetch(heroFetch)
        else {return}
        
        heroesResult.forEach{ hero in
            context.delete(hero)
        }
        
        try? context.save()
    }
}
