import Foundation
import UIKit.UIImage

typealias CellHeroesData = [CellHeroData]

final class CellHeroData{
    let name:String
    let description:String
    let image:UIImage
    
    init(name: String, description: String, image: UIImage) {
        self.name = name
        self.description = description
        self.image = image
    }
}
