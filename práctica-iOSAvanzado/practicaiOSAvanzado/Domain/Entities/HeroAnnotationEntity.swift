import Foundation
import CoreData
import UIKit.UIImage

@objc(HeroAnnotationEntity)
final class HeroAnnotationEntity:NSManagedObject{
    @NSManaged var title: String
    @NSManaged var subtitle: String
    @NSManaged var image: UIImage
    @NSManaged var latitud: Double
    @NSManaged var longitud: Double
}
