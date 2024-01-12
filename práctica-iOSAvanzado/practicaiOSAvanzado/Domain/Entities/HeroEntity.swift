import Foundation
import CoreData
import UIKit.UIImage

@objc(HeroEntity)
final class HeroEntity:NSManagedObject{
    @NSManaged var name: String
    @NSManaged var detail: String
    @NSManaged var image: UIImage
}
