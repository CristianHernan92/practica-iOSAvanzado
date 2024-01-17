import XCTest
import CoreData
@testable import practicaiOSAvanzado

final class CoreDataTest: XCTestCase {
    
    //MARK: -INSTANCIA DE LA BASE DE DATOS-
    //creamos el persistent container el cual usaremos para testear nuestra base de datos (Core Data)
    //instancia de la clase que tiene lo que vamos a testear
    var sut:NSPersistentContainer!
    
    //MARK: -SE EJECUTA ANTES DE CADA TEST (REINICIALIZACIÓN)-
    override func setUp() {
        super.setUp()
        //agregamos el nombre del modelo del core data que usaremos para testear en el cual tenemos las entidades
        sut = NSPersistentContainer(name: "practicaiOSAvanzado")
        //almacen de memoria para la base de datos
        let persistentStoreDescription = NSPersistentStoreDescription()
        persistentStoreDescription.type = NSInMemoryStoreType
        //abrimos el almacen de memoria para a usar en la base de datos
        sut.persistentStoreDescriptions = [persistentStoreDescription]
        sut.loadPersistentStores { (persistentStoreDescription, error) in
            if let error = error { fatalError("No se puede crear el almacén de datos en memoria: \(error)")}
        }
    }
    
    //MARK: -SE EJECUTA DESPUÉS DE CADA TEST (LIMPIEZA)-
    override func tearDown() {
        super.tearDown()
        sut = nil
    }
    
    //MARK: -TESTS-
    func test_EntityCannotBeSavedByOptionalAttributesNotAdded(){
        //context
        let context = sut.newBackgroundContext()
        XCTAssertNotEqual(context, nil, "error: context is nil")
        
        //entity
        let cellHeroDataEntity = CellHeroDataEntity(context: context)
        cellHeroDataEntity.name = "Hero name"
        // non-optional atributes not added must throw a error
        //cellHeroDataEntity.detail = "Hero detail"
        //cellHeroDataEntity.image = UIImage()
        
        //save context
        XCTAssertThrowsError(try context.save())
    }
    
    func test_saveEntity(){
        //context
        let context = sut.newBackgroundContext()
        
        //entity
        let cellHeroDataEntity = CellHeroDataEntity(context: context)
        cellHeroDataEntity.name = "Hero name"
        cellHeroDataEntity.detail = "Hero detail"
        cellHeroDataEntity.image = UIImage()
        
        //save context
        XCTAssertNoThrow(try context.save(), "Error: The context could not be saved")
    }
    
    func test_getEntity(){
        //context
        let context = sut.newBackgroundContext()
        
        //entity
        let cellHeroDataEntity = CellHeroDataEntity(context: context)
        cellHeroDataEntity.name = "Hero name"
        cellHeroDataEntity.detail = "Hero detail"
        cellHeroDataEntity.image = UIImage()
        
        //save context
        XCTAssertNoThrow(try context.save(), "Error: The context could not be saved")
        
        //fetch
        let fetch = NSFetchRequest<CellHeroDataEntity>(entityName: "CellHeroDataEntity")
        let fetchResult = try? context.fetch(fetch)
        
        XCTAssertNotNil(fetchResult)
        XCTAssert(fetchResult!.count > 0)
        
    }
    
    func test_deleteEntity(){
        //context
        let context = sut.newBackgroundContext()
        
        //entity
        let cellHeroDataEntity = CellHeroDataEntity(context: context)
        cellHeroDataEntity.name = "Hero name"
        cellHeroDataEntity.detail = "Hero detail"
        cellHeroDataEntity.image = UIImage()
        
        //save context
        XCTAssertNoThrow(try context.save(), "Error: The context could not be saved")
        
        //fetch
        let fetch = NSFetchRequest<CellHeroDataEntity>(entityName: "CellHeroDataEntity")
        let fetchResult = try? context.fetch(fetch)
        
        XCTAssertNotNil(fetchResult)
        XCTAssert(fetchResult!.count > 0)
        
        fetchResult?.forEach{ cellHeroDetailEntity in
            context.delete(cellHeroDetailEntity)
        }
        
        XCTAssert(try! context.fetch(NSFetchRequest<CellHeroDataEntity>(entityName: "CellHeroDataEntity")).count == 0)
    }
}
