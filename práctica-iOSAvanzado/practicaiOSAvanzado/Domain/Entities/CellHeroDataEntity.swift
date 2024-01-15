import Foundation
import CoreData
import UIKit.UIImage

@objc(CellHeroDataEntity)
final class CellHeroDataEntity:NSManagedObject{
    @NSManaged var name: String
    @NSManaged var detail: String
    @NSManaged var image: UIImage
}
