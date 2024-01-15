import Foundation
import UIKit.UIImage

protocol HeroDetailViewModelProtocol{
    func viewReady()
}

final class HeroDetailViewModel{
    weak var viewController:HeroDetailViewControllerProtocol? = nil
    
    let heroTitle: String
    let heroDetail: String
    let heroImage: UIImage
    
    init(heroTitle:String,heroDetail:String,heroImage:UIImage) {
        self.heroTitle = heroTitle
        self.heroDetail = heroDetail
        self.heroImage = heroImage
    }
}

extension HeroDetailViewModel:HeroDetailViewModelProtocol{
    func viewReady() {
        viewController?.fillData(heroDetail: self.heroDetail, heroTitle: self.heroTitle, heroImage: self.heroImage)
    }
}
